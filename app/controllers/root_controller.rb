# frozen_string_literal: true

class RootController < ApplicationController

  # GET /
  def index
    if Current.user.account
      if property = Current.user.account.properties&.first
        redirect_to property_path(property)
      else
        redirect_to new_property_path
      end
    else
      Current.user.account = Account.new
      render "accounts/new"
    end
  end

end
