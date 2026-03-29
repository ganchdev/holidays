# frozen_string_literal: true

require "test_helper"

class BotVerifyControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @other_user = users(:two)
    @authorized_user = authorized_users(:one)
    @chat_id = "12345678"
  end

  test "should redirect to login if not authenticated" do
    get "/bot_verify", params: { chat_id: @chat_id, email: @user.email_address }

    assert_redirected_to "/auth"
  end

  test "should show error when email does not match logged in user" do
    set_current_user(@user)

    get "/bot_verify", params: { chat_id: @chat_id, email: @other_user.email_address }

    assert_response :success
    assert_includes @response.body, "doesn&#39;t match"
  end

  test "should show code when authenticated with matching email" do
    set_current_user(@user)

    get "/bot_verify", params: { chat_id: @chat_id, email: @user.email_address }

    assert_response :success
  end

  test "should reuse existing verification code for same chat_id" do
    set_current_user(@user)

    get "/bot_verify", params: { chat_id: @chat_id, email: @user.email_address }
    first_code = BotVerification.find_by(chat_id: @chat_id).code

    get "/bot_verify", params: { chat_id: @chat_id, email: @user.email_address }
    second_code = BotVerification.find_by(chat_id: @chat_id).code

    assert_equal first_code, second_code
  end

  test "should show error when email not in authorized users" do
    set_current_user(@user)

    get "/bot_verify", params: { chat_id: @chat_id, email: "nonexistent@example.com" }

    assert_response :success
    assert_includes @response.body, "not found in authorized users"
  end

  test "should redirect when missing parameters" do
    set_current_user(@user)

    get "/bot_verify", params: { chat_id: @chat_id }
    assert_redirected_to "/auth"

    get "/bot_verify", params: { email: @user.email_address }
    assert_redirected_to "/auth"
  end

end
