# frozen_string_literal: true

module Admin
  class UsersController < BaseController

    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      @users = User.all
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if Current.user == @user
        redirect_to admin_users_path, alert: "Cannot delete current user"
      else
        @user.destroy
        redirect_to admin_users_path, notice: "User successfully deleted."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: [:name, :first_name, :last_name, :admin, :account_id])
    end

  end
end
