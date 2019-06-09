module SpotlightSearch
  module ExportableColumns
    cattr_accessor :enabled_columns, :export_enabled

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
      def export_columns(enabled: false, only: nil, except: nil)
        if enabled
          @export_enabled = true
          all_columns = self.column_names.map(&:to_sym)
          if only.present?
            unless (valid_columns = only & all_columns).size == only.size
              invalid_columns = only - valid_columns
              raise SpotlightSearch::Exceptions::InvalidColumns.new(nil, invalid_columns)
            end
            @enabled_columns = only
          else
            @enabled_columns = all_columns
          end
          if except.present?
            unless (valid_columns = except & all_columns).size == only.size
              invalid_columns = except - valid_columns
              raise SpotlightSearch::Exceptions::InvalidColumns.new(nil, invalid_columns)
            end
            @enabled_columns = @enabled_columns - except
          end
        else
          @export_enabled = false
          @enabled_columns = nil
        end
      end

      # Validates whether the selected columns are allowed for export
      def validate_exportable_columns(columns)
        unless columns.is_a?(Array)
          raise SpotlightSearch::Exceptions::InvalidValue.new('Excepted Array. Invalid type received')
        end
        unless (@enabled_columns & columns.map(&:to_sym)) == columns.size
          return false
        end
        return true
      end
    end
  end
end

ActiveRecord::Base.extend SpotlightSearch::ExportableColumns
