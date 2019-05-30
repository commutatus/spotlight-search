module SpotlightSearch
  module Helpers
    
    def sortable(column, title = nil, sort_column="created_at", sort_direction="asc")
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      # link_to title, '#', {:class => css_class, data: {sort: column, direction: direction}}
      content_tag("a","Title", class: css_class, data: {sort_column: column, sort_direction: direction, behaviour: 'sort', type: 'anchor-filter'})
    end

    def cm_paginate(facets)
      tag.div class: 'text-center' do
        tag.div class: 'nav navbar navbar-inner' do
          tag.ul class: 'pagination' do
            if facets.previous_page != false
              previous_page = tag.li do
                tag.button class: 'btn btn-bordered', data: { behaviour: 'previous-page'} do
                  tag.span "Previous"
                end
              end
            end
            current_page = content_tag :li do
              tag.a class: 'btn btn-bordered mx-2', data: {sort_column: @filtered_result.sort[:sort_column], sort_direction: @filtered_result.sort[:sort_direction], page: facets.current_page, behaviour: 'current-page' } do
                "Showing #{facets.current_page} of #{facets.total_pages} pages"
              end
            end

            if facets.next_page != false
              next_page = tag.li do
                tag.button class: 'btn btn-bordered', data: { behaviour: 'next-page'} do
                  tag.span "Next"
                end
              end
            end
            (previous_page || ActiveSupport::SafeBuffer.new) + current_page + (next_page || ActiveSupport::SafeBuffer.new)
          end
        end
      end
    end
  end
end
