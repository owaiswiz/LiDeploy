# config valid only for Capistrano 3.1
lock '3.5.0'

set :application, 'lideploy'
#set :repo_url, 'git@github.com:owaiswiz/host.git'
set :repo_url, 'https://owaiswiz:Owaiskhan1@github.com/owaiswiz/host.git'
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/lideploy'
# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
#set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :bundle_binstubs, nil
set :bundle_env_variables, { 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1 }
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'

#after :restart, :clear_cache do
##on roles(:web), in: :groups, limit: 3, wait: 10 do
#### Here we can do anything such as:
#### within release_path do
##### execute :rake, 'cache:clear'
#### end
##end
#end

end
namespace :rails do
  desc 'Open a rails console `cap [staging] rails:console [server_index default: 0]`'
  task :console do
    server = roles(:app)[ARGV[2].to_i]

    puts "Opening a console on: #{server.hostname}...."

    cmd = "ssh #{server.user}@#{server.hostname} -t 'cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{fetch(:rails_env)} bundle exec rails console'"

    puts cmd

    exec cmd
  end
end
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'delayed_job:restart'
  end
end
