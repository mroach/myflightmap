#!/bin/sh

if [ "$RAILS_ENV" == "production" ]; then
  bundle exec rake assets:precompile
fi

bundle exec puma -C /app/config/puma.rb
