require 'spotlight_search/helpers'

module SpotlightSearch
  class Railtie < Rails::Railtie
    initializer "spotlight_search.helpers" do
      ActionView::Base.send :include, Helpers
    end
  end
end
