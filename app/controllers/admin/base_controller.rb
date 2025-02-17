# frozen_string_literal: true

module Admin
  class BaseController < ActionController::Base

    include Authentication

    layout "admin"

    before_action :ensure_admin

    def ensure_admin
      redirect_to root_path, alert: "Unauthorized" unless Current.user&.admin?
    end

  end
end
