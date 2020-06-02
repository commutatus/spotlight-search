module SpotlightSearch
  module Generators
    class FilterGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      argument :model,                type: :string, required: true, desc: "Pass a model name"
      class_option :init_js,          type: :boolean, default: false, desc: "Pass true if you're gonna export input filters"
      class_option :filters,          aliases: "-f", type: :array, desc: "Pass filters and scopes as an array. E.x: date_filter:datetime search:input"

      def initialize_js_packages
        if @options.init_js?
          system("yarn add jquery")
          system("yarn add coffeescript")
          system("yarn add select2")
          inject_into_file 'app/assets/stylesheets/application.css', before: " */" do
            " *= require select2\n"
          end        
          unless File.directory?("app/javascript/application/coffee_scripts")
            Dir.mkdir("app/javascript/application")
            Dir.mkdir("app/javascript/application/coffee_scripts")
          end
          template "application.js.template", "app/javascript/packs/application.js"
          template 'scaffolds.coffee.template', "app/javascript/application/coffee_scripts/scaffolds.coffee"        
        end
      end

      def copy_filter_contents_to_app
        if @options.filters?
          unless File.directory?("app/views/#{model}")
            Dir.mkdir("app/views/#{model}")
          end
          template 'filters.html.erb.template', "app/views/#{model}/_filters.html.slim"
        end
      end

    end
  end
end