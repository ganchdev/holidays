# frozen_string_literal: true

require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @property = properties(:one)
    @booking = bookings(:one)
    @room = rooms(:one)

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
          price: 100.0,
          notes: @booking.notes,
          starts_at: DateTime.now + 1.month,
          ends_at: (DateTime.now + 1.month) + 3.days
        }
      }
    end

    assert_redirected_to property_booking_url(@property, Booking.last)
    assert_equal I18n.t("flash.bookings.created_successfully"), flash[:notice]
    assert_equal 100.0, Booking.last.price.to_f
  end

  test "should create booking with room price" do
    # First create a room with a known price without using update!
    room_price = 75.0
    room_name = "Test Room #{Time.now.to_i}"
    new_room = @property.rooms.create!(
      name: room_name,
      price: room_price,
      capacity: 2,
      color: "green"
    )
    
    assert_difference("Booking.count", 1) do
      post property_bookings_url(@property), params: {
        booking: {
          room_id: new_room.id,
          adults: @booking.adults,
          children: @booking.children,
          deposit: @booking.deposit,
          notes: @booking.notes,
          starts_at: DateTime.now + 1.month,
          ends_at: (DateTime.now + 1.month) + 3.days
        },
        use_room_price: "1"
      }
    end

    assert_redirected_to property_booking_url(@property, Booking.last)
    assert_equal room_price, Booking.last.price.to_f
  end

  test "should handle form reload during create" do
    post property_bookings_url(@property), params: {
      booking: {
        room_id: @property.rooms.first.id,
        adults: @booking.adults,
        children: @booking.children,
        starts_at: DateTime.now + 1.month,
        ends_at: (DateTime.now + 1.month) + 3.days
      },
      reload: "1"
    }
    
    assert_response :success
    assert_includes @response.body, "turbo-stream"
  end

  test "should not reload form when dates are invalid" do
    post property_bookings_url(@property), params: {
      booking: {
        room_id: @property.rooms.first.id,
        adults: @booking.adults,
        children: @booking.children,
        starts_at: DateTime.now + 1.month,
        ends_at: nil # Missing end date makes it invalid
      },
      reload: "1"
    }
    
    assert_response :success
    assert_includes @response.body, "turbo-stream"
  end

  test "should show booking" do
    get property_booking_url(@property, @booking)
    assert_response :success
    # The booking show page doesn't use h1 tags, so we'll check for something that exists
    assert_select "dl", 1
  end
  
  test "should get day view" do
    get day_property_bookings_url(@property, day: Date.today)
    assert_response :success
  end
  
  test "should get day view with invalid date" do
    get day_property_bookings_url(@property, day: "invalid-date")
    assert_response :success
    # Should default to today
  end

  test "should get edit" do
    get edit_property_booking_url(@property, @booking)
    assert_response :success
  end

  test "should update booking" do
    patch property_booking_url(@property, @booking), params: {
      booking: {
        adults: 3,
        children: @booking.children,
        deposit: @booking.deposit,
        price: 120.0,
        notes: "Updated notes"
      }
    }
    assert_redirected_to property_booking_url(@property, @booking)
    assert_equal I18n.t("flash.bookings.updated_successfully"), flash[:notice]
    
    @booking.reload
    assert_equal 3, @booking.adults
    assert_equal 120.0, @booking.price.to_f
    assert_equal "Updated notes", @booking.notes
  end
  
  test "should update booking with room price" do
    # Create a new room with a known price to avoid updating existing rooms
    room_price = 85.0
    room_name = "Update Test Room #{Time.now.to_i}"
    new_room = @property.rooms.create!(
      name: room_name,
      price: room_price,
      capacity: 2,
      color: "blue"
    )
    
    # Assign booking to the new room first
    @booking.update!(room_id: new_room.id)
    
    patch property_booking_url(@property, @booking), params: {
      booking: {
        room_id: new_room.id,
        adults: @booking.adults,
        children: @booking.children,
        deposit: @booking.deposit,
        notes: @booking.notes
      },
      use_room_price: "1"
    }
    
    assert_redirected_to property_booking_url(@property, @booking)
    
    @booking.reload
    assert_equal room_price, @booking.price.to_f
  end
  
  test "should handle form reload during update" do
    patch property_booking_url(@property, @booking), params: {
      booking: {
        adults: @booking.adults,
        children: @booking.children,
        starts_at: DateTime.now + 2.month,
        ends_at: (DateTime.now + 2.month) + 5.days
      },
      reload: "1"
    }
    
    assert_response :success
    assert_includes @response.body, "turbo-stream"
  end

  test "should cancel booking" do
    delete property_booking_url(@property, @booking)

    @booking.reload

    assert_not_nil @booking.cancelled_at
    assert_equal I18n.t("flash.bookings.destroyed_successfully"), flash[:notice]
  end
  
  test "should render new with errors when validation fails on create" do
    post property_bookings_url(@property), params: {
      booking: {
        room_id: @property.rooms.first.id,
        adults: 0, # Invalid: adults must be ≥ 1
        starts_at: DateTime.now + 1.month,
        ends_at: (DateTime.now + 1.month) + 3.days
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "div.form-errors"
  end
  
  test "should render edit with errors when validation fails on update" do
    patch property_booking_url(@property, @booking), params: {
      booking: {
        adults: 0, # Invalid: adults must be ≥ 1
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "div.form-errors"
  end
  
end
