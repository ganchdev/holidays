# frozen_string_literal: true

source "https://rubygems.org"

gem "annotaterb"
gem "dotenv-rails"
gem "importmap-rails"
gem "octicons"
gem "octicons_helper"
gem "omniauth"
gem "omniauth-github", "~> 2.0.0"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.1"
gem "sqlite3", ">= 2.1"
gem "stimulus-rails"
gem "turbo-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

group :development, :test do
  gem "pry-remote"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "rbs"
  gem "rbs-inline", require: false
  gem "rbs_rails", require: false
  gem "steep"
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "mocha"
  gem "selenium-webdriver"
end
