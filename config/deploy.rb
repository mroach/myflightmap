lock '3.2.1'

# Load the secrets file. We need it for the Rollbar key
secrets = YAML.load(File.read('config/secrets.yml'))[fetch(:rails_env, 'production').to_s]

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

set :linked_files, %w{config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
#set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
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

end

after 'deploy:publishing', 'deploy:restart'
after 'deploy:finishing', 'deploy:cleanup'
