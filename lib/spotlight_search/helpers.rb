module SpotlightSearch
  module Helpers
    def sortable(column, title = nil, sort_column="created_at", sort_direction="asc")
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      # link_to title, '#', {:class => css_class, data: {sort: column, direction: direction}}
      content_tag("a","Title", class: css_class, data: {sort_column: column, sort_direction: direction, behaviour: 'sort', type: 'anchor-filter'})
    end
  end
end
