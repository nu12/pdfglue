FROM ruby:2.7.1-alpine as builder

# Set ARG in hooks/build to use Dockerhub autobuild
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production \
    NODE_ENV=production

WORKDIR /app

COPY . /app/

RUN apk add --no-cache nodejs yarn build-base tzdata postgresql-dev \
 # Install gems
 && bundle config set without 'development test' \
 && bundle install \
 # Install & compile yarn packages
 && yarn install --production \
 && bin/rails webpacker:compile \
 && bin/rails assets:precompile \
 # Remove unneeded files (cached *.gem, *.o, *.c)
 && ls /usr/local/bundle \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete \
 # Remove folders not needed in resulting image
 && rm -rf node_modules tmp/cache vendor/assets spec

FROM ruby:2.7.1-alpine

WORKDIR /app

ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

RUN apk add --no-cache ghostscript postgresql-client tzdata

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app/ /app/

EXPOSE 3000

ENTRYPOINT ["sh", "entrypoint.sh"]

# Smaller rails images:
# https://medium.com/@lemuelbarango/ruby-on-rails-smaller-docker-images-bff240931332