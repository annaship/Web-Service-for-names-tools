set :application, "neti_taxonfinder"
set :repository, "svn://code01.ubio.org/names_tools/webservices/ruby/trunk"

set :scm, :subversion

set :deploy_to, "/data/web/neti_taxonfinder"
server "128.128.164.209", :app, :web, :db, :primary => true
set :user, "root"
set :use_sudo, false
# set :scm_username, "anna"

set :app_server, :passenger

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  
  desc "Copy Production Configuration"
  task :copy_production_configuration do
    run "cp #{current_release}/config/production_config.yml #{current_release}/config/config.yml"
  end
  after "deploy:update_code", :copy_production_configuration
end
