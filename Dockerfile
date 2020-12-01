FROM ruby:2.7.1-alpine as builder

ENV RAILS_ENV=production

WORKDIR /app

COPY Gemfile package.json yarn.lock /app/

RUN apk add --no-cache nodejs yarn build-base tzdata postgresql-dev \
 && bundle config set without 'development test' \
 && bundle install

COPY . /app/

RUN bin/rails assets:precompile

FROM ruby:2.7.1-alpine

WORKDIR /app

ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

RUN apk add --no-cache ghostscript postgresql-dev tzdata

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app/ /app/

EXPOSE 3000

ENTRYPOINT ["sh", "entrypoint.sh"]