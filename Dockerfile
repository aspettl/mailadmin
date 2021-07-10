FROM ruby:2.7.4-alpine AS builder

RUN apk update \
 && apk add build-base zlib-dev tzdata openssl-dev mariadb-dev shared-mime-info nodejs yarn \
 && rm -rf /var/cache/apk/*

WORKDIR /app

ADD Gemfile Gemfile.lock ./

RUN gem install bundler -v $(tail -n1 Gemfile.lock | xargs) \
 && bundle config set --local deployment 'true' \
 && bundle config set --local without 'development test' \
 && bundle config set --local build.sassc '--disable-march-tune-native' \
 && bundle install

ADD package.json yarn.lock ./

RUN yarn install

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=irrelevant bundle exec rails assets:precompile

RUN rm -rf node_modules


FROM ruby:2.7.4-alpine
LABEL maintainer="aaron@spettl.de"

RUN apk update \
 && apk add zlib tzdata libssl1.1 mariadb-connector-c shared-mime-info \
 && rm -rf /var/cache/apk/*

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
ENV SECRET_KEY_BASE your-rails-secret
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ENV MAILSERVER_HOSTNAME mail.example.com
ENV WEBMAIL_HOSTNAME webmail.example.com
ENV API_TOKEN your-secret-token
ENV CONFIGRELOAD_WEBHOOK ""

EXPOSE $PORT

CMD bundle exec rails db:migrate \
 && bundle exec puma -C config/puma.rb
