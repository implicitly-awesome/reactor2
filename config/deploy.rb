load 'deploy' if respond_to?(:namespace)

require 'bundler/capistrano'
require 'rvm/capistrano'

#server "192.168.1.55", :web, :app, :db, primary: true
server "ec2-54-244-164-253.us-west-2.compute.amazonaws.com", :web, :app, :db, primary: true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "improva.pem")]

set :application,   "reactor2"
set :user,          "ubuntu"
set :deploy_to,     "/home/#{user}/apps/#{application}"
set :rails_env,     "production"
set :use_sudo,      false
set :keep_releases, 5

set :scm,           :git
set :branch,        "master"
set :repository,    "git@github.com:madeinussr/#{application}"
set :deploy_via,    :remote_cache
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

#after 'deploy:update_code', :roles => :app do
#  # Здесь для примера вставлен только один конфиг с приватными данными - database.rb. Обычно для таких вещей создают папку /srv/myapp/shared/config и кладут файлы туда. При каждом деплое создаются ссылки на них в нужные места приложения.
#  run "rm -f #{current_release}/config/database.rb"
#  run "ln -s #{deploy_to}/shared/config/database.rb #{current_release}/config/database.rb"
#end

after "deploy:setup", "deploy:setup_config"
after "deploy:finalize_update", "deploy:symlink_config"
after 'deploy', 'deploy:cleanup', 'deploy:stop', 'deploy:start'

namespace :deploy do
  task :start  do
    run "cd #{current_path} && RACK_ENV=production bundle exec thin -C config/thin.yml"# -R config.ru start
    sudo "/etc/init.d/nginx start"
  end

  task :stop do
    run "cd #{current_path} && RACK_ENV=production bundle exec thin -C config/thin.yml"# -R config.ru stop
    sudo "/etc/init.d/nginx stop"
  end

  #task :restart do
  #  run "cd #{current_path} && bundle exec thin stop -C config/thin.yml config.ru stop"
  #  run "cd #{current_path} && bundle exec thin start -C config/thin.yml config.ru start"
  #  sudo "/etc/init.d/nginx stop"
  #  sudo "/etc/init.d/nginx start"
  #end

  task :setup_config, roles: :app do
    sudo "chmod ugo+rwx /opt/nginx/conf/nginx.conf"
    put File.read("config/nginx.conf"), "/opt/nginx/conf/nginx.conf"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.rb"), "#{shared_path}/config/database.rb"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.rb #{release_path}/config/database.rb"
  end

  task :cold do
    deploy.update
    deploy.start
  end

  #task :set_gems do
  #  run "cd #{current_path}"
  #  run "bundle install --path vendor/bundle"
  #  sudo "service nginx restart"
  #end

  def disabled_rvm_shell(&block)
    old_shell = self[:default_shell]
    self[:default_shell] = nil
    yield
    self[:default_shell] = old_shell
  end
end