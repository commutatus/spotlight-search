require 'axlsx'

module SpotlightSearch
  class ExportJob < ApplicationJob
    def perform(email, klass, columns = [], filters = {})
      klass = klass.constantize
      records = get_records(klass, filters, columns)
      file_path = create_excel(records, klass.name, columns)
      subject = "#{klass.name} export at #{Time.now}"
      ExportMailer.send_excel_file(email, file_path, subject).deliver_now
      File.delete(file_path)
    end

    def get_records(klass, filters, columns)
      records = klass
      if filters
        if filters['filters'].present?
          filters['filters'].each do |scope, scope_args|
            if scope_args.is_a?(Array)
              records = records.send(scope, *scope_args)
            else
              records = records.send(scope, scope_args)
            end
          end
        end
        if filters['sort'].present?
          records = records.order("#{filters['sort']['sort_column']} #{filters['sort']['sort_direction']}")
        end
      end
      columns = columns.map(&:to_sym)
      records.select(*columns)
    end

    # Creating excel with the passed records
    # Keys as headers and values as row
    def create_excel(records, klass, columns)
      size_arr = []
      columns.size.times { size_arr << 22 }
      xl = Axlsx::Package.new
      xl.workbook.add_worksheet do |sheet|
        sheet.add_row columns, b: true
        records.each do |record|
          sheet.add_row columns.map { |column| record.send(column) }
        end
        sheet.column_widths *size_arr
      end
      file_location = "#{Rails.root}/public/export_#{klass}_#{Time.now.to_s}.xls"
      xl.serialize(file_location)
      file_location
    end
  end
end
