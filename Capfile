# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/rails'

require 'capistrano/rbenv'

require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'rollbar/capistrano3'

require 'capistrano/puma'
require 'capistrano/puma/nginx'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
