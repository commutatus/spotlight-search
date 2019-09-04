SpotlightSearch::Engine.routes.draw do
  post '/export_to_file', to: 'spotlight_search/export_jobs#export_job'
end
