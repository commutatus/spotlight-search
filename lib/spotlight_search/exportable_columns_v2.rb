module SpotlightSearch
  module ExportableColumnsV2
    extend ActiveSupport::Concern

    module ClassMethods
      # Enables or disables export and specifies which all columns can be
      # exported. For enabling export for all columns in all models
      #
      #   class ApplicationRecord < ActiveRecord::Base
      #     export_columns enabled: true
      #   end
      #
      # For disabling export for only specific models
      #
      #   class Person < ActiveRecord::Base
      #     export_columns enabled: false
      #   end
      #
      # For allowing export for only specific columns in a model
      #
      #   class Person < ActiveRecord::Base
      #     export_columns enabled: true, only: [:created_at, :updated_at]
      #   end
      #
      # For excluding only specific columns and allowing all others
      #
      #   class Person < ActiveRecord::Base
      #     export_columns enabled: true, except: [:created_at, :updated_at]
      #   end
      #
      def export_columns(*record_fields, **associated_fields)
        self.enabled_columns = [*record_fields, **associated_fields]
      end

      def _model_exportable_columns(klass, *record_fields, **associated_fields)
        # Gets all the valid columns of a model
        # If any column is invalid, it also returns it
        raise SpotlightSearch::Exceptions::InvalidValue, "Expected ActiveRecord::Base, Received #{klass}" unless klass < ActiveRecord::Base

        valid_columns = []
        invalid_columns = []

        # Base case: verify all the columns that belong to this record
        record_fields.each do |field|
          klass.new.respond_to?(field) ? valid_columns << field : invalid_columns << field
        end

        # Recursive case: check all associations and verify that they are all valid too
        associated_fields.each do |association, association_record_fields|
          reflection = klass.reflect_on_association(association)
          invalid_columns << association && next unless reflection # Add whole association to invalid columns if it doesn't exist

          case reflection
          when ActiveRecord::Reflection::BelongsToReflection, ActiveRecord::Reflection::HasOneReflection
            if reflection.polymorphic?
              # We cannot process them further, so we'll assume it works and call it a day
              valid_columns << { association => association_record_fields }
            else
              columns_hash = _model_exportable_columns(reflection.klass, *association_record_fields)
              valid_columns << { association => columns_hash[:valid_columns] }
              invalid_columns << { association => columns_hash[:invalid_columns] } if columns_hash[:invalid_columns].size.positive?
            end
          else
            # one to many relationshops cannot be supported
            invalid_columns << association
            next
          end
        end

        # return all the valid and invalid columns in a hash
        {
          valid_columns: valid_columns,
          invalid_columns: invalid_columns
        }
      end

      # Validates whether the selected columns are allowed for export
      def validate_exportable_columns(columns)
        unless columns.is_a? Array
          raise SpotlightSearch::Exceptions::InvalidValue, 'Expected Array. Invalid type received'
        end
        (columns & SpotlightSearch::Utils.serialize_csv_columns(*enabled_columns)).size == columns.size # returns true if all columns are valid
      end
    end

    included do
      class_attribute :enabled_columns, instance_accessor: false, default: nil
    end
  end
end
