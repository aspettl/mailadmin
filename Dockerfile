FROM ruby:3.4.2-slim-bookworm AS builder

RUN apt-get update && apt-get install -y build-essential libmariadb-dev libyaml-dev && rm -rf /var/lib/apt/lists/*

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


FROM ruby:3.4.2-slim-bookworm
LABEL maintainer="aaron@spettl.de"

RUN apt-get update && apt-get install -y libmariadb3 libyaml-0-2 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN addgroup --system --gid 101 app \
 && adduser --system --uid 101 --ingroup app --home /app app \
 && chown -R app:app /app

USER 101

COPY --from=builder --chown=app:app /app .

RUN bundle config --local path vendor/bundle \
 && bundle config set --local without 'development test'

ENV PORT=3000
ENV RAILS_ENV=production
ENV DATABASE_URL="mysql2://myuser:mypass@hostname/somedatabase"
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

ENV MAILSERVER_HOSTNAME=mail.example.com
ENV WEBMAIL_HOSTNAME=webmail.example.com
ENV API_TOKEN=""
ENV CONFIGRELOAD_WEBHOOK=""

EXPOSE $PORT

CMD ["/app/entrypoint.sh"]
