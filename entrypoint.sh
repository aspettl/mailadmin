#!/bin/bash
set -Eeuo pipefail

bundle exec rails db:migrate

exec bundle exec puma -C config/puma.rb
