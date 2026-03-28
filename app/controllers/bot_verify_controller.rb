# frozen_string_literal: true

class BotVerifyController < ApplicationController
  allow_unauthenticated_access only: [:show]
  before_action :verify_email_match

  def show
    @chat_id = params[:chat_id]
    @email = params[:email]

    return redirect_to "/auth", alert: "Missing chat_id or email" if @chat_id.blank? || @email.blank?

    @authorized_user = AuthorizedUser.find_by(email_address: @email)

    if @authorized_user.nil?
      @error = "Email not found in authorized users"
      return
    end

    if @authorized_user.user.nil?
      @error = "No user associated with this email"
      return
    end

    verification = BotVerification.find_or_initialize_by(chat_id: @chat_id)
    verification.authorized_user = @authorized_user
    verification.save!

    @code = verification.code
  end

  private

  def verify_email_match
    @email = params[:email]

    if Current.user.nil?
      redirect_to "/auth", alert: "Please log in first"
      return
    end

    if Current.user.email_address.downcase != @email.to_s.downcase
      @error = "The email address doesn't match your logged-in account. Please use the email associated with your account."
    end
  end

end
