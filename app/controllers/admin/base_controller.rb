# frozen_string_literal: true

module Admin
  class BaseController < ActionController::Base

    include Authentication

    layout "admin"

    before_action :ensure_admin
    before_action :set_locale

    def ensure_admin
      redirect_to root_path, alert: t("common.unauthorized") unless Current.user&.admin?
    end

    def set_locale
      I18n.locale = :en
    end

  end
end
