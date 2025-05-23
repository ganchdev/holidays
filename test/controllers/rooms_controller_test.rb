# frozen_string_literal: true

require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @property = properties(:one)
    @room = rooms(:room_without_bookings)
    @user = users(:one)

    set_current_user(@user)
  end

  test "should get index" do
    get property_rooms_url(@property)
    assert_response :success
  end

  test "should get new" do
    get new_property_room_url(@property)
    assert_response :success
  end

  test "should create room" do
    assert_difference("Room.count", 1) do
      post property_rooms_url(@property), params: { room: { name: "New Room", capacity: 10, color: "Blue" } }
    end
    assert_redirected_to property_rooms_path(@property)
    assert_equal I18n.t("flash.rooms.created_successfully"), flash[:notice]
  end

  test "should get edit" do
    get edit_property_room_url(@property, @room)
    assert_response :success
  end

  test "should update room" do
    patch property_room_url(@property, @room), params: { room: { name: "Updated Name", capacity: 15, color: "Red" } }
    assert_redirected_to property_rooms_path(@property)
    assert_equal I18n.t("flash.rooms.updated_successfully"), flash[:notice]
    @room.reload
    assert_equal "Updated Name", @room.name
    assert_equal 15, @room.capacity
    assert_equal "Red", @room.color
  end

  test "should destroy room" do
    assert_difference("Room.count", -1) do
      delete property_room_url(@property, @room)
    end
    assert_redirected_to property_rooms_url(@property)
    assert_equal I18n.t("flash.rooms.destroyed_successfully"), flash[:notice]
  end

end
