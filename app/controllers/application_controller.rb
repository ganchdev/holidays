# frozen_string_literal: true

class ApplicationController < ActionController::Base

  include Authentication

  before_action :find_account

  rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_record_not_destroyed_error

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  private

  def find_account
    return unless Current.user

    Current.account = Current.user.account
  end

  def handle_record_not_destroyed_error(exception)
    redirect_to request.referer || root_path, alert: exception.record.errors.full_messages.to_sentence
  end

end
