module SpotlightSearch
  module ExportableColumns
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
      def export_columns(enabled: false, only: nil, except: nil, associated: nil)
        ActiveRecord::Base.connection.migration_context.needs_migration? && return
        return unless enabled

        self.export_enabled = true
        all_columns = self.column_names.map(&:to_sym)
        if only.present?
          unless (valid_columns = only & all_columns).size == only.size
            invalid_columns = only - valid_columns
            raise SpotlightSearch::Exceptions::InvalidColumns, invalid_columns
          end
          self.enabled_columns = only
        else
          self.enabled_columns = all_columns
        end
        if except.present?
          unless (valid_columns = except & all_columns).size == except.size
            invalid_columns = except - valid_columns
            raise SpotlightSearch::Exceptions::InvalidColumns, invalid_columns
          end
          self.enabled_columns = self.enabled_columns - except
        end
      rescue ActiveRecord::NoDatabaseError
        Rails.logger.info("No database error")
      end

      # Validates whether the selected columns are allowed for export
      def validate_exportable_columns(columns)
        unless columns.is_a?(Array)
          raise SpotlightSearch::Exceptions::InvalidValue.new('Expected Array. Invalid type received')
        end
        unless (self.enabled_columns & columns.map(&:to_sym)) == columns.size
          return false
        end
        return true
      end
    end

    included do
      class_attribute :enabled_columns, instance_accessor: false, default: nil
      class_attribute :export_enabled, instance_accessor: false, default: false
    end
  end
end
