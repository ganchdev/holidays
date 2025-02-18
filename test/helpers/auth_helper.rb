# frozen_string_literal: true

module AuthHelper

  def set_current_user(user)
    ApplicationController.any_instance.stubs(:require_authentication).returns(false)
    Current.stubs(:user).returns(user)
  end

end
