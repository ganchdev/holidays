# frozen_string_literal: true

require "test_helper"

class PropertiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts(:one)
    @property = properties(:one)
    @user = users(:one)

    set_current_user(@user)
    Current.account = @account
  end

  test "should get index" do
    get account_properties_url(@account)
    assert_response :success
  end

  test "should get new" do
    get new_account_property_url(@account)
    assert_response :success
  end

  test "should create property" do
    assert_difference("Property.count", 1) do
      post account_properties_url(@account), params: { property: { name: "New Property" } }
    end
    assert_redirected_to account_property_path(@account, Property.last)
  end

  test "should show property" do
    get account_property_url(@account, @property)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_property_url(@account, @property)
    assert_response :success
  end

  test "should update property" do
    patch account_property_url(@account, @property), params: { property: { name: "Updated Name" } }
    assert_redirected_to account_property_path(@account, @property)
    @property.reload
    assert_equal "Updated Name", @property.name
  end

  test "should destroy property" do
    assert_difference("Property.count", -1) do
      delete account_property_url(@account, @property)
    end
    assert_redirected_to account_properties_url(@account)
  end

end
