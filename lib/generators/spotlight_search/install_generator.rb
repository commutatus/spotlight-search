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
        copy_file 'spotlight_search.rb', 'config/initializers/spotlight_search.rb'
        copy_file 'application.css.scss', 'app/assets/stylesheets/application.css.scss'
        route "mount SpotlightSearch::Engine => '/spotlight_search'"
      end

      def add_essentials
        system("yarn add jquery coffeescript coffee-loader select2 popper.js daterangepicker bootstrap-datepicker")
        template "application.js", "app/javascript/packs/application.js"
        template 'scaffolds.coffee', "app/javascript/application/coffee_scripts/scaffolds.coffee"
        gem 'kaminari'
      end

    end
  end
end
