set :application, "netineti"
set :repository, "svn://code01.ubio.org/names_tools/netineti/trunk"

set :scm, :subversion

set :deploy_to, "/data/netineti"
server "128.128.164.206", :app, :web, :db, :primary => true
set :user, "root"
set :password, "neti90"
set :use_sudo, false
# set :scm_username, "anna"

set :app_server, :passenger

after "deploy:update_code", "deploy:copy_production_configuration" 

namespace :deploy do
  # desc "Restart Application"
  # task :restart, :roles => :app do
  #   nohup python neti-server.py &
  #   run "nohup python neti-server.py &"
  # end

  task :start, :roles => [:web, :app] do
    # run "cd #{deploy_to}/current && nohup python neti-server.py &"
    run "ps -ef | grep neti-server.py"
  end

  task :stop, :roles => [:web, :app] do
    run "killall neti-server"
  end

  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
  
  desc "Copy production configuration"
  task :copy_production_configuration do
    run "cp #{current_release}/config/production_env/config.yml #{current_release}/config/config.yml"
  end
  
  # desc "Kill the proce"
end

