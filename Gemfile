# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 8.0.2'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 6.6'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.13'
# Required by jbuilder in combination with Ruby 3.5.0 because ostruct is removed from the standard library
gem 'ostruct', '>= 0.6.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Authentication framework
gem 'devise'

# We use the bcrypt library to generate account passwords
gem 'bcrypt'

# We use the 'Have I been pwned?'-API to check passwords
gem 'pwned'

# Helper for generating the breadcrumb navigation
gem 'breadcrumbs_on_rails'

# Save blank values as NULL in the database
gem 'nilify_blanks'

# Bring back memoize for Rails
gem 'memoist'

# Reduces boot times through caching; required in config/boot.rb
# Note: with Ruby 3.0.3, we need at least version 1.9.2 to work around https://bugs.ruby-lang.org/issues/18250
gem 'bootsnap', '>= 1.9.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Static code analysis / linter
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  # gem 'listen', '~> 3.3'
  # gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.11.0'
  # Bring back "assigns" in controller tests
  gem 'rails-controller-testing'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
