ActiveRecord::Base.include SpotlightSearch::ExportableColumnsV2

SpotlightSearch.setup do |config|
  config.exportable_columns_version = :v2
end
