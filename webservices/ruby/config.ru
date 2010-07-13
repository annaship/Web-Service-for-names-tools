require 'rubygems'
require 'taxon_finder_web_service'
set :run, false
set :environment, :production
run Sinatra::Application
