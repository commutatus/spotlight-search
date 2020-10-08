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

    def exportable(email, klass, html_class: [])
      tag.a "Export as excel", class: html_class.append("filter-btn modal-btn mr-2"), data: {toggle: "modal", target: "#exportmodal"} do
        concat tag.i class: 'fa fa-download'
        concat tag.span " Excel"
      end
    end

    def column_pop_up(email, klass, required_filters = nil)
      tag.div class: "modal fade", id: "exportmodal", tabindex: "-1", role: "dialog", aria: {labelledby: "exportModal"} do
        tag.div class: "modal-dialog modal-lg", role: "document" do
          tag.div class: "modal-content" do
            concat pop_ups(email, klass, required_filters)
          end
        end
      end
    end

    def pop_ups(email, klass, required_filters)
      tag.div do
        concat pop_up_header
        concat pop_up_body(email, klass, required_filters)
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

    def pop_up_body(email, klass, required_filters)
      tag.div class: "modal-body" do
        form_tag '/spotlight_search/export_to_file', id: 'export-to-file-form', style: "width: 100%;", class:"spotlight-csv-export-form" do
          concat hidden_field_tag 'email', email, id: 'export-to-file-email'
          concat hidden_field_tag 'class_name', klass.to_s, id: 'export-to-file-klass'
          filters_to_post_helper(required_filters) if required_filters
          params_to_post_helper(filters: controller.filter_params) if controller.filter_params
          params_to_post_helper(sort: controller.sort_params) if controller.sort_params
          case SpotlightSearch.exportable_columns_version
          when :v1
            concat checkbox_row(klass)
          when :v2
            concat checkbox_row_v2(klass)
          end
          concat tag.hr
          concat submit_tag 'Export as excel', class: 'btn btn-primary btn-bordered export-to-file-btn'
        end
      end
    end

    def filters_to_post_helper(required_filters)
      URI.decode_www_form(required_filters.to_param).each do |param|
        concat hidden_field_tag "filters[#{param[0]}]", param[1]
      end      
    end

    def params_to_post_helper(params)
      URI.decode_www_form(params.to_param).each do |param|
        concat hidden_field_tag param[0], param[1]
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

    def filter_wrapper(data_behaviours, classes=nil)
      tag.div class: "filter-wrapper d-flex filters #{classes}", data: data_behaviours do
        yield
      end
    end

    def cm_filter_tag(input_type, scope_name, value, classes = nil, placeholder = nil)
      case input_type
      when 'input'
        tag.div class: 'filter-field' do
          concat text_field_tag scope_name, '', class: "#{classes}", data: {behaviour: "filter", scope: scope_name, type: "input-filter"}, placeholder: "#{placeholder}"
          concat tag.span class: 'fa fa-search search-icon'
        end
      when 'single-select'
        tag.div class: 'filter-field' do
          select_tag scope_name, options_for_select(value), class: "#{classes} select2-single", data: {behaviour: "filter", scope: scope_name, type: "select-filter"}, include_blank: "#{placeholder}"
        end
      when 'multi-select'
        tag.div class: 'filter-field' do
          select_tag scope_name, options_for_select(value), class: "#{classes} select2-single", data: {behaviour: "filter", scope: scope_name, type: "select-filter"}, include_blank: "#{placeholder}", multiple: true
        end
      when 'datetime'
        tag.div class: 'filter-field' do
          concat text_field_tag scope_name, '', class: "#{classes}", data: {behaviour: "filter", scope: scope_name, type: "input-filter", provide: "datepicker"}, placeholder: "#{placeholder}"
          concat tag.span class: 'fa fa-search search-icon'
        end
      when 'daterange'
        tag.div class: 'filter-field' do
          concat text_field_tag scope_name, '', class: "#{classes} filter-rangepicker", data: {behaviour: "filter", scope: scope_name, type: "range-filter"}, placeholder: "#{placeholder}"
          concat tag.span class: 'fa fa-search search-icon'
        end
      end
    end

    def clear_filters(clear_path, classes=nil, data_behaviours=nil, clear_text=nil)
      link_to "#{clear_text}", clear_path, class: "#{classes}", data: data_behaviours
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
        concat check_box_tag "columns[]", column_path, id: column_path.to_s.gsub('/', '-')
        concat " " + column_path.to_s.gsub('/', '_').humanize
      end
    end

    def cm_paginate(facets)
      tag.div class: 'cm-pagination' do
        tag.div class: 'nav navbar navbar-inner' do
          tag.ul class: 'pagination' do
            if facets.previous_page != false
              previous_page = tag.li do
                tag.button class: 'cm-pagination__item', data: { behaviour: 'previous-page'} do
                  tag.span "Previous"
                end
              end
            end
            current_page = content_tag :li do
              tag.button class: 'cm-pagination__item', data: {sort_column: facets.sort[:sort_column], sort_direction: facets.sort[:sort_direction], page: facets.current_page, behaviour: 'current-page' } do
                "Showing #{facets.current_page} of #{facets.total_pages} pages"
              end
            end

            if facets.next_page != false
              next_page = tag.li do
                tag.button class: 'cm-pagination__item', data: { behaviour: 'next-page'} do
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
