FROM ruby:3.3.1-alpine3.19 AS builder

RUN apk --no-cache add build-base zlib-dev tzdata openssl-dev mariadb-dev shared-mime-info

WORKDIR /app

ADD Gemfile Gemfile.lock ./

RUN gem install bundler -v $(tail -n1 Gemfile.lock | xargs) \
 && bundle config set --local deployment 'true' \
 && bundle config set --local without 'development test' \
 && bundle config set --local build.sassc '--disable-march-tune-native' \
 && bundle install \
 && find vendor/bundle/ -name '*.o' -delete

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=irrelevant bundle exec rails assets:precompile


FROM ruby:3.3.1-alpine3.19
LABEL maintainer="aaron@spettl.de"

RUN apk --no-cache add zlib tzdata libssl3 mariadb-connector-c shared-mime-info

WORKDIR /app

RUN addgroup -g 101 -S app \
 && adduser -u 101 -S app -G app -h /app \
 && chown -R app:app /app

USER 101

COPY --from=builder --chown=app:app /app .

RUN bundle config --local path vendor/bundle \
 && bundle config set --local without 'development test'

ENV PORT 3000
ENV RAILS_ENV production
ENV DATABASE_URL "mysql2://myuser:mypass@hostname/somedatabase"
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ENV MAILSERVER_HOSTNAME mail.example.com
ENV WEBMAIL_HOSTNAME webmail.example.com
ENV API_TOKEN ""
ENV CONFIGRELOAD_WEBHOOK ""

EXPOSE $PORT

CMD bundle exec rails db:migrate \
 && bundle exec puma -C config/puma.rb
