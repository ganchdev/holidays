# frozen_string_literal: true

class ApplicationController < ActionController::Base

  include Authentication

  before_action :find_account

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def find_account
    return unless Current.user

    Current.account = Current.user.account
  end

end
