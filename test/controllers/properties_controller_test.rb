# frozen_string_literal: true

require "test_helper"

class PropertiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @property = properties(:one)
    @user = users(:one)

    set_current_user(@user)
  end

  test "should get index" do
    get properties_url
    assert_response :success
  end

  test "should get new" do
    get new_property_url
    assert_response :success
  end

  test "should create property" do
    assert_difference("Property.count", 1) do
      post properties_url, params: { property: { name: "New Property" } }
    end
    assert_redirected_to property_path(Property.last)
  end

  test "should show property" do
    get property_url(@property)
    assert_response :success
  end

  test "should get edit" do
    get edit_property_url(@property)
    assert_response :success
  end

  test "should update property" do
    patch property_url(@property), params: { property: { name: "Updated Name" } }
    assert_redirected_to property_path(@property)
    @property.reload
    assert_equal "Updated Name", @property.name
  end

  test "should destroy property" do
    assert_difference("Property.count", -1) do
      delete property_url(@property)
    end
    assert_redirected_to properties_url
  end

end
