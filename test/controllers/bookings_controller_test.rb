# frozen_string_literal: true

require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @property = properties(:one)
    @room = rooms(:one)
    @booking = bookings(:one)

    @room.bookings << @booking

    set_current_user(@user)
  end

  test "should get index" do
    get property_room_bookings_url(@property, @room)
    assert_response :success
  end

  test "should get new" do
    get new_property_room_booking_url(@property, @room)
    assert_response :success
  end

  test "should create booking" do
    assert_difference("Booking.count", 1) do
      post property_room_bookings_url(@property, @room), params: {
        booking: {
          adults: @booking.adults,
          children: @booking.children,
          deposit: @booking.deposit,
          notes: @booking.notes,
          starts_at: DateTime.now + 1.month,
          ends_at: (DateTime.now + 1.month) + 3.days
        }
      }
    end

    assert_redirected_to property_room_booking_url(@property, @room, Booking.last)
  end

  test "should show booking" do
    get property_room_booking_url(@property, @room, @booking)
    assert_response :success
  end

  test "should get edit" do
    get edit_property_room_booking_url(@property, @room, @booking)
    assert_response :success
  end

  test "should update booking" do
    patch property_room_booking_url(@property, @room, @booking), params: {
      booking: {
        adults: @booking.adults,
        children: @booking.children,
        deposit: @booking.deposit,
        notes: @booking.notes
      }
    }
    assert_redirected_to property_room_booking_url(@property, @room, @booking)
  end

  test "should destroy booking" do
    assert_difference("Booking.count", -1) do
      delete property_room_booking_url(@property, @room, @booking)
    end

    assert_redirected_to property_room_bookings_url(@property, @room)
  end

end
