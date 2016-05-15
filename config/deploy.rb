lock '3.2.1'

# Load the secrets file. We need it for the Rollbar key
secrets = YAML.load(File.read('config/application.yml'))[fetch(:rails_env, 'production').to_s]

set :application, 'myflightmap'
set :repo_url, 'git@github.com:mroach/myflightmap.git'

set :rbenv_type, :user
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

set :rollbar_token, secrets['rollbar']
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

set :puma_threads, [4, 16]
set :puma_workers, 0

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/home/deploy/apps/myflightmap'
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :linked_files, %w{}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, { devise_secret_key: "herp", secret_key_base: "derp" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
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

after 'deploy:publishing', 'deploy:restart'
after 'deploy:finishing', 'deploy:cleanup'

after "deploy:started", "figaro:setup"
after "deploy:symlink:release", "figaro:symlink"
