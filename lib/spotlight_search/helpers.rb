module SpotlightSearch
  module Helpers

    def sortable(column, title = nil, sort_column="created_at", sort_direction="asc")
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      # link_to title, '#', {:class => css_class, data: {sort: column, direction: direction}}
      content_tag("a","Title", class: css_class, data: {sort_column: column, sort_direction: direction, behaviour: 'sort', type: 'anchor-filter'})
    end

    def exportable(email, klass)
      tag.button "Export as excel", class: "modal-btn", data: {toggle: "modal", target: "#exportmodal"}
      tag.div class: "modal fade", id: "exportmodal", tabindex: "-1", role: "dialog", aria: {labelledby: "exportModal"} do
        tag.div class: "modal-dialog", role: "document" do
          tag.div class: "modal-content" do
            tag.div class: "modal-header" do
              tag.button type: "button", class: "close", data: {dismiss: "modal"}, aria: {label: "Close"} do
                tag.span "X", aria: {hidden: "true"}
              end
              tag.h4 "Select columns to export", class: "modal-title", id: "exportModal"
            end
            tag.div class: "modal-body" do
              form_tag '/export_to_file', id: 'export-to-file-form' do
                hidden_field_tag 'email', email, id: 'export-to-file-email'
                hidden_field_tag 'filters', nil, id: 'export-to-file-filters'
                hidden_field_tag 'klass', klass.to_s, id: 'export-to-file-klass'
                klass.enabled_columns.each do |column_name|
                  tag.div class: "row" do
                    tag.div class: "col-md-4" do
                      check_box_tag "columns[]", column_name
                    end
                  end
                end
                submit_tag 'Export as excel', class: 'btn btn-bordered export-to-file-btn'
              end
            end
          end
        end
      end
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
              tag.a class: 'btn btn-bordered mx-2', data: {sort_column: facets.sort[:sort_column], sort_direction: facets.sort[:sort_direction], page: facets.current_page, behaviour: 'current-page' } do
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
