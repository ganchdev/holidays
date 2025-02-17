# frozen_string_literal: true

require "test_helper"

module Admin
  class AccountsControllerTest < ActionDispatch::IntegrationTest

    test "should get index" do
      get admin_accounts_index_url
      assert_response :success
    end

    test "should get show" do
      get admin_accounts_show_url
      assert_response :success
    end

    test "should get new" do
      get admin_accounts_new_url
      assert_response :success
    end

    test "should get edit" do
      get admin_accounts_edit_url
      assert_response :success
    end

    test "should get create" do
      get admin_accounts_create_url
      assert_response :success
    end

    test "should get update" do
      get admin_accounts_update_url
      assert_response :success
    end

    test "should get destroy" do
      get admin_accounts_destroy_url
      assert_response :success
    end

  end
end
