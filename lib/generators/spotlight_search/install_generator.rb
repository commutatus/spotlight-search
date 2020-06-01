require 'yaml'

module SpotlightSearch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_webpacker_gem_assets
        copy_file 'webpacker_gem_assets.rb', 'config/initializers/webpacker_gem_assets.rb'
      end

      def add_essentials
        append_to_file "app/javascript/packs/application.js" do 
          "require ('spotlight_search')"
        end
        gem 'kaminari', '~> 1.2.1'
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