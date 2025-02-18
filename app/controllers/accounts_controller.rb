# frozen_string_literal: true

class AccountsController < ApplicationController

  before_action :redirect_if_account_exists

  # POST /a
  def create
    @account = Current.user.create_account!(params.require(:account).permit(:name))
    Current.user.update(account: @account)

    redirect_to root_path, notice: t("flash.accounts.created_successfully")
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def redirect_if_account_exists
    return unless Current.user.account.present?

    redirect_to root_path, alert: t("flash.accounts.already_has_account")
  end

end
