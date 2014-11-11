source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1'

# Need >= 3.1 for bootstrap 3 support
gem 'simple_form', '3.1.0.rc1'

# Country drop-down
gem 'country_select'

# Dropdown replacement with AJAX support
gem "select2-rails"

# Date picker
gem "pickadate-rails"

# Use devise for the auth and registration framework https://github.com/plataformatec/devise
gem 'devise'

# Allow Facebook auth in devise
gem 'omniauth-facebook'

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Needed to figure out the time at the airport
gem 'tzinfo'

# XML parser, handy for parsing HTML for scraping
gem 'nokogiri'

# HTTParty for consuming JSON APIs
gem 'httparty'

# Nice country helper. Among other things, parse names into ISO codes
gem 'countries'

# Attaching files to records
gem 'paperclip'

# Nice lib for dealing with durations of time and formatting them
gem "ruby-duration"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Bootstrap for general site layouts
gem 'bootstrap-sass', '~> 3.3.0'

# Add Font Awesome support (icons as font glyphs)
gem 'font-awesome-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Change tracking for ActiveRecord models
gem "audited-activerecord", "~> 4.0"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use unicorn as the app server
# gem 'unicorn'

group :development do
  gem 'capistrano', '~> 3.2.1'
  gem 'sqlite3'

  # needed for CSV parsing
  gem 'stdlib'

  # allows organization of data seeding tasks
  gem 'seedbank'

  # generate files for an application layout, navigation links, and flash messages
  gem 'rails_layout'

  # Hush the asset pipeline logging
  gem 'quiet_assets'
end

gem 'capistrano-bundler', '~> 1.1.2'

gem 'capistrano-rails', '~> 1.1.1'

gem 'capistrano-rbenv', '~> 2.0'

# use PostgreSQL in testing and development modes
gem 'pg', group: [:development, :test]

# Use byebug for debugging
gem 'byebug', group: [:development, :test]
