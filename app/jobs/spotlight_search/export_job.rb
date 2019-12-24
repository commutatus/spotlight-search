require 'axlsx'

module SpotlightSearch
  class ExportJob < ApplicationJob
    def perform(klass, email, columns = [], filters = {}, sort = {})
      records = get_records(klass, columns, filters, sort)
      file_path =
        case SpotlightSearch.exportable_columns_version
        when :v1
          create_excel(records, klass.name, columns)
        when :v2
          create_excel_v2(records, klass.name)
        end
      subject = "#{klass.name} export at #{Time.now}"
      ExportMailer.send_excel_file(email, file_path, subject).deliver_now
      File.delete(file_path)
    end

    def get_records(klass, columns, filters, sort)
      records = klass
      if filters.present?
        filters.each do |scope, scope_args|
          records = records.send(scope, scope_args)
        end
      end
      if sort.present?
        records = records.order("#{sort['sort_column']} #{sort['sort_direction']}")
      end
      if filters.blank? && sort.blank?
        records = records.all
      end
      case SpotlightSearch.exportable_columns_version
      when :v1
        columns = columns.map(&:to_sym)
        records.select(*columns)
      when :v2
        records.as_json(SpotlightSearch::Utils.deserialize_csv_columns(columns, :as_json_params))
      end
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

    def create_excel_v2(records, class_name)
      flattened_records = records.map { |record| SpotlightSearch::Utils.flatten_hash(record) }
      columns = flattened_records[0].keys
      size_arr = []
      columns.size.times { size_arr << 22 }
      xl = Axlsx::Package.new
      xl.workbook.add_worksheet do |sheet|
        sheet.add_row columns, b: true
        flattened_records.each do |record|
          sheet.add_row(columns.map { |column| record[column] })
        end
        sheet.column_widths(*size_arr)
      end
      file_location = "#{Rails.root}/public/export_#{class_name}_#{Time.now.to_s}.xls"
      xl.serialize(file_location)
      file_location
    end
  end
end
