require 'spotlight_search/engine'
require 'spotlight_search/version'
require 'spotlight_search/railtie' if defined?(Rails)

module SpotlightSearch
  extend ActiveSupport::Concern
  module ClassMethods
    def filter_by(page, filter_params = {}, sort_params = {})
      filtered_result = OpenStruct.new
      sort_column = self.column_names.include?(sort_params[:sort_column]) ? sort_params[:sort_column] : "created_at"
      sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
      sort_params = {sort_column: sort_column, sort_direction: sort_direction}
      raw_data = self.filter(filter_params).sort_list(sort_column, sort_direction)
      filtered_result.data = raw_data.page(page).per(30)
      filtered_result.facets = self.paginate(page, raw_data.size)
      filtered_result.sort = sort_params
      filtered_result.facets.sort = sort_params

      return filtered_result
    end

    def filter(filter_params)
      data = self
      if filter_params.present? && filter_params.class == ActiveSupport::HashWithIndifferentAccess
        filter_params.each do |key, value|
          data = data.send(key, value)
        end
      else
        data = self.all
      end
      return data
    end

    def sort_list(sort_column, sort_direction)
      return self.order(sort_column + " " + sort_direction)
    end

    def paginate(page, total_count)
      page = page.presence || 1
      per_page = 30
      facets = OpenStruct.new # initializing OpenStruct instance
      facets.total_count = total_count
      facets.filtered_count = total_count
      facets.total_pages = (total_count/per_page.to_f).ceil
      facets.current_page = page.to_i
      # Previous Page
      if facets.current_page - 1 == 0
        facets.previous_page = false
      else
        facets.previous_page = true
      end
      # Next Page
      if facets.current_page + 1 > facets.total_pages
        facets.next_page = false
      else
        facets.next_page = true
      end
      return facets
    end
  end

end
