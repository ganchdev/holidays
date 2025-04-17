# frozen_string_literal: true

require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @property = properties(:one)
    @booking = bookings(:one)

    set_current_user(@user)
  end

  test "should get index" do
    get property_bookings_url(@property)
    assert_response :success
  end

  test "should get new" do
    get new_property_booking_url(@property)
    assert_response :success
  end

  test "should create booking" do
    assert_difference("Booking.count", 1) do
      post property_bookings_url(@property), params: {
        booking: {
          room_id: @property.rooms.first.id,
          adults: @booking.adults,
          children: @booking.children,
          deposit: @booking.deposit,
          notes: @booking.notes,
          starts_at: DateTime.now + 1.month,
          ends_at: (DateTime.now + 1.month) + 3.days
        }
      }
    end

    assert_redirected_to property_booking_url(@property, Booking.last)
  end

  test "should show booking" do
    get property_booking_url(@property, @booking)
    assert_response :success
  end

  test "should get edit" do
    get edit_property_booking_url(@property, @booking)
    assert_response :success
  end

  test "should update booking" do
    patch property_booking_url(@property, @booking), params: {
      booking: {
        adults: @booking.adults,
        children: @booking.children,
        deposit: @booking.deposit,
        notes: @booking.notes
      }
    }
    assert_redirected_to property_booking_url(@property, @booking)
  end

  test "should cancel booking" do
    delete property_booking_url(@property, @booking)

    @booking.reload

    assert_not_nil @booking.cancelled_at
  end

end
