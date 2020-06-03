module SpotlightSearch
  module Generators
    class FilterGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      argument :model,                type: :string, required: true, desc: "Pass a model name"
      class_option :filters,          aliases: "-f", type: :array, desc: "Pass filters and scopes as an array. E.x: date_filter:datetime search:input"

      def copy_filter_contents_to_app
        if @options.filters?
          template 'filters.html.erb', "app/views/admin/#{model}/_filters.html.slim"
          template 'controller.rb.erb', "app/controllers/admin/#{model}_controller.rb"
        end
      end

    end
  end
end
