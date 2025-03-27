# frozen_string_literal: true

module Admin
  class AccountsController < BaseController

    before_action :find_account, only: [:edit, :update, :destroy]

    def index
      @accounts = Account.all
    end

    def new
      @account = Account.new
    end

    def edit
    end

    def create
      @account = Account.new(account_params)

      if @account.save
        redirect_to admin_accounts_path, notice: "Account successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @account.update(account_params)
        redirect_to admin_accounts_path, notice: "Account successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @account.destroy
      redirect_to admin_accounts_path, notice: "Account successfully deleted."
    end

    private

    def find_account
      @account = Account.find(params[:id])
    end

    def account_params
      params.expect(account: [:name])
    end

  end
end
