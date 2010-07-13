set :application, "neti_reconciliation_demo"
set :repository, "svn://code01.ubio.org/names_tools/webservices/demo_clients/neti_reconciliation_demo/trunk"

set :scm, :subversion

set :deploy_to, "/data/web/neti_reconciliation_demo"
server "128.128.164.209", :app, :web, :db, :primary => true
set :user, "root"
set :use_sudo, false
# set :scm_username, "anna"

set :app_server, :passenger

after "deploy:update_code", "deploy:copy_production_configuration" 

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Copy production configuration"
  task :copy_production_configuration do
    run "cp #{current_release}/config/production_config.yml #{current_release}/config/config.yml"
    run "cp #{current_release}/config/production_config.rb #{current_release}/config/config.rb"
  end
end

