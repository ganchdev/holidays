# frozen_string_literal: true

class AccountsController < ApplicationController

  before_action do
    if Current.user.account.present?
      redirect_to root_path, alert: "You already have an account."
    end
  end

  # POST /a
  def create
    @account = Current.user.create_account!(params.expect(account: :name))
    Current.user.update(account: @account)

    redirect_to root_path, notice: "Account was successfully created."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

end
