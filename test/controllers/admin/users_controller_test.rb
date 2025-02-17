# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest

    test "should get index" do
      get admin_users_index_url
      assert_response :success
    end

    test "should get show" do
      get admin_users_show_url
      assert_response :success
    end

    test "should get edit" do
      get admin_users_edit_url
      assert_response :success
    end

    test "should get destroy" do
      get admin_users_destroy_url
      assert_response :success
    end

  end
end
