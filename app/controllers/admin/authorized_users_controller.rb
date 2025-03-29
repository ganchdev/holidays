# frozen_string_literal: true

module Admin
  class AuthorizedUsersController < BaseController

    before_action :set_authorized_user, only: [:edit, :update, :destroy]

    def index
      @authorized_users = AuthorizedUser.all
    end

    def new
      @authorized_user = AuthorizedUser.new
    end

    def edit
    end

    def create
      @authorized_user = AuthorizedUser.new(authorized_user_params)

      if @authorized_user.save
        redirect_to admin_authorized_users_path, notice: "Authorized user successfully created."
      else
        @authorized_users = AuthorizedUser.all
        render :index, status: :unprocessable_entity
      end
    end

    def update
      if @authorized_user.update(authorized_user_params)
        redirect_to admin_authorized_users_path, notice: "Authorized user successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @authorized_user.destroy
      redirect_to admin_authorized_users_path, notice: "Authorized user successfully deleted."
    end

    private

    def set_authorized_user
      @authorized_user = AuthorizedUser.find(params[:id])
    end

    def authorized_user_params
      params.expect(authorized_user: [:email_address, :account_id, :user_id])
    end

  end
end
