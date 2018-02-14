FROM ruby:2.4-alpine

ARG RAILS_ENV="development"

RUN apk add --update --no-cache \
    build-base tzdata coreutils bash \
    nodejs postgresql-dev \
    libxml2-dev libxslt-dev

RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir /app
WORKDIR /app

ENV BUNDLE_PATH /ruby_gems

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs=/app/bin

COPY . .

CMD docker/app.sh
