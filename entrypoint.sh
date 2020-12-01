#!/bin/bash

sleep 10

RAILS_ENV=production bundle exec rake db:migrate

rails s -b 0.0.0.0