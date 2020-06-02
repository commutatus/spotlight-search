module SpotlightSearch
  module Generators
    class FilterGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      argument :model,                type: :string, required: true, desc: "Pass a model name"
      class_option :is_input,         type: :boolean, desc: "Pass true if you're gonna export input filters"
      class_option :is_select,        type: :boolean, desc: "Pass true if you're gonna export select filters"
      class_option :input_filters,    type: :array, desc: "Scopes of input filters"
      class_option :select_filters,   type: :array, desc: "Scopes of select filters"

      def copy_filter_contents_to_app
        unless File.directory?("app/views/#{model}")
          Dir.mkdir("app/views/#{model}")
        end
        template 'filters.html.erb.template', "app/views/#{model}/_filters.html.slim"
      end

      def copy_table_contents_to_app
        unless File.directory?("app/views/#{model}")
          Dir.mkdir("app/views/#{model}")
        end
        template 'table.html.erb.template', "app/views/#{model}/_table.html.slim"
      end

    end
  end
end