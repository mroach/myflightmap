lock '3.5.0'

# Load the secrets file. We need it for the Rollbar key
secrets = YAML.load(File.read('config/application.yml'))

set :application, 'myflightmap'
set :deploy_to, '/home/deploy/apps/myflightmap'
set :deploy_via, :remote_cache
set :scm, :git
set :repo_url, 'git@github.com:mroach/myflightmap.git'
set :keep_releases, 10

set :log_level, :debug
set :pty, true

set :rbenv_type,     :user
set :rbenv_ruby,     File.read('.ruby-version').strip
set :rbenv_prefix,   "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles,    :all # default value

set :rollbar_token, secrets.fetch('ROLLBAR')
set :rollbar_env,   Proc.new { fetch :stage }
set :rollbar_role,  Proc.new { :app }

set :puma_threads, [4, 16]
set :puma_workers, 0

set :puma_bind,               "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_conf,               "#{release_path}/config/puma.rb"
set :puma_state,              "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,                "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log,         "#{release_path}/log/puma.error.log"
set :puma_error_log,          "#{release_path}/log/puma.access.log"
set :ssh_options,             { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app,        true
set :puma_worker_timeout,     nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

set :foreman_use_sudo, false # Set to :rbenv for rbenv sudo, :rvm for rvmsudo or true for normal sudo
set :foreman_roles, :all
set :foreman_template, 'systemd'
set :foreman_export_path, "#{shared_path}/init"
set :foreman_options, ->{ {
  app: fetch(:application),
  log: File.join(shared_path, 'log'),
  root: release_path,
  user: fetch(:user)
} }

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :linked_files, %w{}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
      invoke 'puma:nginx_config'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,  :check_revision
  after  :finishing, :compile_assets
  after  :finishing, :cleanup
  after  :finishing, :restart
end

namespace :figaro do
  desc "SCP transfer figaro configuration to the shared folder"
  task :setup do
    on roles(:app) do
      upload! "config/application.yml", "#{shared_path}/config/application.yml", via: :scp
    end
  end

  desc "Symlink application.yml to the release path"
  task :symlink do
    on roles(:app) do
      execute "ln -sf #{shared_path}/config/application.yml #{current_path}/config/application.yml"
    end
  end
end
