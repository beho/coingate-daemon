# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'coingate-daemon'
set :repo_url, 'ssh://git@coingate.lan/project/repositories/coingate-daemon.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/coingate/coingate-daemon'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/interop.yml config/rabbitmq.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp vendor/bundle}

set :bundle_bins, fetch(:bundle_bins, []).push( 'bluepill' )

set :environment_variable, 'RACK_ENV'
set :whenever_roles, ->{ :cron }
# set :whenever_environment, ->{ 'RACK_ENV=production' }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Migrate database'
  task :migrate do
    on roles(:db), in: :sequence, wait: 5 do
      within release_path do
        execute :rake, 'db:migrate'
        execute :rake, 'db:seed'
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:daemon), in: :sequence, wait: 5 do
      begin # bluepill may not be running, but that is not necessarily an error
        invoke 'bluepill:quit'
      rescue
      ensure
        invoke 'bluepill:start'
      end
    end
  end

  after :updated, :migrate
  after :publishing, :restart

end
