# frozen_string_literal: true

require "test_helper"

module Admin
  class AuthorizedUsersControllerTest < ActionDispatch::IntegrationTest

    test "should get index" do
      get admin_authorized_users_index_url
      assert_response :success
    end

    test "should get show" do
      get admin_authorized_users_show_url
      assert_response :success
    end

    test "should get new" do
      get admin_authorized_users_new_url
      assert_response :success
    end

    test "should get edit" do
      get admin_authorized_users_edit_url
      assert_response :success
    end

    test "should get destroy" do
      get admin_authorized_users_destroy_url
      assert_response :success
    end

  end
end
