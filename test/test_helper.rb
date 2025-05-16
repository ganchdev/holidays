# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "minitest/autorun"
require "helpers/auth_helper"

module ActiveSupport
  class TestCase

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include AuthHelper

    setup do
      # Set a consistent locale for all tests to ensure predictable translations
      I18n.locale = :en
    end

    # Helper method to switch locale if needed for specific tests
    def with_locale(locale)
      original_locale = I18n.locale
      I18n.locale = locale
      yield
    ensure
      I18n.locale = original_locale
    end

  end
end
