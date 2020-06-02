require 'yaml'

module SpotlightSearch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_webpacker_gem_assets
        copy_file 'webpacker_gem_assets.rb', 'config/initializers/webpacker_gem_assets.rb'
        copy_file 'webpacker.yml', 'config/webpacker.yml'
        copy_file 'environment.js', 'config/webpack/environment.js'
        copy_file 'coffee.js', 'config/webpack/loaders/coffee.js'
      end

      def add_essentials
        system("yarn add jquery")
        system("yarn add coffeescript")
        system("yarn add select2")
        inject_into_file 'app/assets/stylesheets/application.css.scss', before: " */" do
          " *= require select2\n"
        end
        template "application.js", "app/javascript/packs/application.js"
        template 'scaffolds.coffee', "app/javascript/application/coffee_scripts/scaffolds.coffee"
        gem 'kaminari', '~> 1.2.1' unless File.readlines("Gemfile").grep(/kaminari/).size > 0
      end

      def edit_webpacker_yml
        webpacker = YAML::load_file('config/webpacker.yml')
        webpacker['default']['resolved_gems_output_path'] = '/tmp/_add_gem_paths.js'
        webpacker['default']['resolved_gems'] = ['spotlight_search']
        webpacker['default']['extensions'] = '.coffee'
        webpacker['production']['webpack_compile_output'] = true
        File.open('config/webpacker.yml', 'w') {|f| f.write webpacker.to_yaml }
      end

    end
  end
end
