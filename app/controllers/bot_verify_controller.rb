# frozen_string_literal: true

class BotVerifyController < ApplicationController
  skip_before_action :require_authentication

  def show
    @chat_id = params[:chat_id]
    @email = params[:email]

    return render json: { error: "Missing chat_id or email" }, status: :bad_request if @chat_id.blank? || @email.blank?

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
end
