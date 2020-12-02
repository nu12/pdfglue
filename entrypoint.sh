#!/bin/bash

sleep 10

export SECRET_KEY_BASE=$(bin/rake secret)

RAILS_ENV=production bundle exec rake db:migrate

rails s -b 0.0.0.0