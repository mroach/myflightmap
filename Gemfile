source 'https://rubygems.org'
source 'https://rails-assets.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1'

# App configuration manager
gem 'figaro'

# Need >= 3.1 for bootstrap 3 support
gem 'simple_form', '~> 3.1'

# Nice country helper. Among other things, parse names into ISO codes
gem 'countries'

# Country drop-down (uses data from countries gem)
gem 'country_select'

# Support SLIM templating engine
gem 'slim'

# Dropdown replacement with AJAX support
gem "select2-rails"

# Date picker
gem "pickadate-rails"

# Advanced querying with ActiveRecord
gem "arel"

# Model security
gem "pundit"

# Decorators
gem "draper"

# Use devise for the auth and registration framework
gem 'devise'

# Allow Facebook and Google auth in devise
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Needed to figure out the time at the airport
gem 'tzinfo'

# XML parser, handy for parsing HTML for scraping
gem 'nokogiri'

# Markdown
gem 'redcarpet'

# HTTParty for consuming JSON APIs
gem 'httparty'

# Attaching files to records
gem 'paperclip'

# Nice lib for dealing with durations of time and formatting them
gem "ruby-duration"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Bootstrap for general site layouts
gem 'bootstrap-sass', '~> 3.3.0'

# Add Font Awesome support (icons as font glyphs)
gem 'font-awesome-rails', '~> 4.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Automatically add CSS prefixes when necessary
gem "autoprefixer-rails"

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# Pseudo-gems for Bower packages
gem 'rails-assets-handlebars'
gem 'rails-assets-typeahead.js'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Change tracking for ActiveRecord models
gem "audited-activerecord", "~> 4.0"

# Easily slugged URLs
gem 'friendly_id', '~> 5.0.0'

# Generate unique, reversible IDs
gem 'hashids'

# Error reporting
gem 'rollbar', '~> 1.3'

group :development do
  gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-bundler', '~> 1.1.2', require: false
  gem 'capistrano-rails', '~> 1.1.1', require: false
  gem 'capistrano-rbenv', '~> 2.0', require: false

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

group :test do
  gem 'coveralls', require: false
end

# use PostgreSQL in staging and production
gem 'pg', group: [:staging, :production]

# Application performance monitoring
gem 'newrelic_rpm', group: [:staging, :production]
