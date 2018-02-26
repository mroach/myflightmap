#!/bin/sh

if [ "$AUTO_DBMIGRATE" == "1" ]; then
  bundle exec rake db:migrate
fi

if [ "$RAILS_ENV" == "production" ]; then
  bundle exec rake assets:precompile
fi

bundle exec puma -C /app/config/puma.rb
