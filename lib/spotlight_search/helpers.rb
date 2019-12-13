module SpotlightSearch
  module Helpers
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::TagHelper

    def sortable(column, title = "Title", sort_column="created_at", sort_direction="asc")
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      # link_to title, '#', {:class => css_class, data: {sort: column, direction: direction}}
      content_tag("a", title, class: css_class, data: {sort_column: column, sort_direction: direction, behaviour: 'sort', type: 'anchor-filter'})
    end

    def exportable(email, klass)
      tag.div do
        concat tag.button "Export as excel", class: "modal-btn", data: {toggle: "modal", target: "#exportmodal"}
        concat column_pop_up(email, klass)
      end
    end

    def column_pop_up(email, klass)
      tag.div class: "modal fade", id: "exportmodal", tabindex: "-1", role: "dialog", aria: {labelledby: "exportModal"} do
        tag.div class: "modal-dialog modal-lg", role: "document" do
          tag.div class: "modal-content" do
            concat pop_ups(email, klass)
          end
        end
      end
    end

    def pop_ups(email, klass)
      tag.div do
        concat pop_up_header
        concat pop_up_body(email, klass)
      end
    end

    def pop_up_header
      tag.div class: "modal-header" do
        tag.button type: "button", class: "close", data: {dismiss: "modal"}, aria: {label: "Close"} do
          tag.span "X", aria: {hidden: "true"}
        end
        tag.h4 "Select columns to export", class: "modal-title", id: "exportModal"
      end
    end

    def pop_up_body(email, klass)
      tag.div class: "modal-body" do
        form_tag '/spotlight_search/export_to_file', id: 'export-to-file-form', style: "width: 100%;" do
          concat hidden_field_tag 'email', email, id: 'export-to-file-email'
          concat hidden_field_tag 'filters', nil, id: 'export-to-file-filters'
          concat hidden_field_tag 'klass', klass.to_s, id: 'export-to-file-klass'
          case SpotlightSearch.exportable_columns_version
          when :v1
            concat checkbox_row(klass)
          when :v2
            concat checkbox_row_v2(klass)
          end
          concat submit_tag 'Export as excel', class: 'btn btn-bordered export-to-file-btn'
        end
      end
    end

    def checkbox_row(klass)
      tag.div class: "row" do
        klass.enabled_columns.each do |column_name|
          concat create_checkbox(column_name)
        end
      end
    end

    def create_checkbox(column_name)
      tag.div class: "col-md-4" do
        concat check_box_tag "columns[]", column_name.to_s
        concat column_name.to_s.humanize
      end
    end

    def checkbox_row_v2(klass)
      tag.div class: "row" do
        SpotlightSearch::Utils.serialize_csv_columns(*klass.enabled_columns).each do |column_path|
          concat create_checkbox_v2(column_path)
        end
      end
    end

    def create_checkbox_v2(column_path)
      tag.div class: "col-md-4" do
        concat check_box_tag "columns[]", column_path
        concat column_path.to_s.split('/').last.humanize
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
