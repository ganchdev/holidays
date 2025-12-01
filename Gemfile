# frozen_string_literal: true

source "https://rubygems.org"

gem "annotaterb", "4.14.0"
gem "dotenv-rails", "3.1.7"
gem "importmap-rails", "2.1.0"
gem "octicons", "19.15.1"
gem "octicons_helper", "19.15.1"
gem "omniauth", "2.1.3"
gem "omniauth-github", "2.0.1"
gem "omniauth-google-oauth2", "1.2.1"
gem "omniauth-rails_csrf_protection", "1.0.2"
gem "propshaft", "1.1.0"
gem "puma", "6.6.0"
gem "rails", "8.1.1"
gem "sqlite3", "2.6.0"
gem "stimulus-rails", "1.3.4"
gem "turbo-rails", "2.0.13"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "3.1.20"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable", "3.0.7"
gem "solid_cache", "1.0.7"
gem "solid_queue", "1.1.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.18.4", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "0.1.12", require: false

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
