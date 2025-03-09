# frozen_string_literal: true

require "test_helper"

class PropertiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @property = properties(:one)
    @user = users(:one)

    set_current_user(@user)
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

  test "should not destroy property with bookings" do
    assert_no_difference("Property.count") do
      delete property_url(@property), headers: { "HTTP_REFERER" => properties_url }
    end

    assert_redirected_to properties_url
    follow_redirect!
    assert_match I18n.t("activerecord.errors.models.property.restrict_dependent_destroy.has_many", record: "bookings"),
                 response.body
  end

  test "should destroy property without bookings" do
    property_without_bookings = properties(:without_bookings)

    assert_difference("Property.count", -1) do
      delete property_url(property_without_bookings)
    end
    assert_redirected_to properties_url
  end

end
