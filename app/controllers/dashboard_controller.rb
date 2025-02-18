# frozen_string_literal: true

class DashboardController < ApplicationController

  # GET /
  def index
    return if Current.user.account

    Current.user.account = Account.new
    render "accounts/new"
  end

end
