FROM ruby:2.7.6-alpine as builder

# Set ARG in hooks/build to use Dockerhub autobuild
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production \
    NODE_ENV=production

WORKDIR /app

COPY . /app/

RUN apk add --no-cache build-base tzdata postgresql-dev \
 # Install gems
 && bundle config set without 'development test' \
 && bundle install \
 && bin/rails assets:precompile \
 # Remove unneeded files (cached *.gem, *.o, *.c)
 && ls /usr/local/bundle \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete \
 # Remove folders not needed in resulting image
 && rm -rf tmp/cache vendor/assets spec

FROM ruby:2.7.6-alpine

WORKDIR /app

ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

RUN apk add --no-cache poppler-utils imagemagick postgresql-client tzdata

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app/ /app/

EXPOSE 3000

ENTRYPOINT ["sh", "entrypoint.sh"]

# Smaller rails images:
# https://medium.com/@lemuelbarango/ruby-on-rails-smaller-docker-images-bff240931332