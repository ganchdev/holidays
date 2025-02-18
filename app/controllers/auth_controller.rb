# frozen_string_literal: true

class AuthController < ApplicationController

  layout "auth"

  allow_unauthenticated_access only: [:new, :callback]
  rate_limit to: 10, within: 3.minutes, only: :new, with: :redirect_on_rate_limit

  before_action :redirect_if_authenticated, only: [:new, :callback]

  # GET /auth/:provider/callback
  def callback
    auth_data = request.env["omniauth.auth"]["info"]

    unless AuthorizedUser.exists?(email_address: auth_data["email"])
      redirect_to auth_path, alert: t("flash.auth.unauthorized")
      return
    end

    begin
      user = find_or_create_user(auth_data)
      start_new_session_for(user)
      redirect_to after_authentication_url
    rescue ActiveRecord::RecordInvalid
      redirect_to auth_path, alert: t("flash.auth.sign_in_error")
    rescue StandardError => e
      Rails.logger.error("OmniAuth callback error: #{e.message}")
      redirect_to auth_path, alert: t("flash.auth.authentication_failed")
    end
  end

  # DELETE|GET /logout
  def destroy
    terminate_session
    redirect_to auth_path, notice: t("flash.auth.logged_out")
  end

  private

  def redirect_if_authenticated
    return unless authenticated?

    redirect_to root_path, alert: t("flash.auth.already_logged_in")
  end

  def redirect_on_rate_limit
    redirect_to auth_path, alert: t("flash.auth.rate_limited")
  end

  def find_or_create_user(auth_data)
    user = User.find_or_initialize_by(email_address: auth_data["email"]) do |u|
      u.name = auth_data["name"]
      u.first_name = auth_data["first_name"]
      u.last_name = auth_data["last_name"]
      u.image = auth_data["image"]
    end

    user.save! if user.new_record?
    user
  end

end
