# frozen_string_literal: true

require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user_without_account = users(:without_account)
    @user_with_account = users(:one)
    @account = accounts(:one)

    set_current_user(@user)
  end

  test "should redirect to root if user already has an account" do
    Current.stubs(:user).returns(@user_with_account)

    get new_account_url

    assert_redirected_to root_path
    assert_equal I18n.t("flash.accounts.already_has_account"), flash[:alert]
  end

  test "should create account for user without account" do
    Current.stubs(:user).returns(@user_without_account)

    assert_difference("Account.count", 1) do
      post accounts_url, params: { account: { name: "Test Account" } }
    end

    assert_redirected_to root_path
    assert_equal I18n.t("flash.accounts.created_successfully"), flash[:notice]

    @user_without_account.reload
    assert_not_nil @user_without_account.account_id
  end

  test "should not create account with invalid params" do
    Current.stubs(:user).returns(@user_without_account)

    assert_no_difference("Account.count") do
      post accounts_url, params: { account: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

end
