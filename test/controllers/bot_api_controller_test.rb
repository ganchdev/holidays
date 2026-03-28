# frozen_string_literal: true

require "test_helper"

class BotApiControllerTest < ActionDispatch::IntegrationTest

  setup do
    # Ensure all test data is in Account.first
    # First, clean up any existing data not in Account.first
    Account.where.not(id: Account.first.id).destroy_all

    # Now create test data in Account.first
    @account = Account.first
    @user = User.create!(
      account: @account,
      email_address: "test@example.com",
      name: "Test User",
      first_name: "Test",
      last_name: "User"
    )

    @property = Property.create!(
      account: @account,
      name: "Test Property"
    )

    @room = Room.create!(
      property: @property,
      name: "Test Room",
      capacity: 2,
      price: 100
    )

    @booking = Booking.create!(
      room: @room,
      name: "Test Guest",
      adults: 2,
      children: 1,
      starts_at: Date.today + 30,
      ends_at: Date.today + 33,
      price: 200
    )
  end

  test "should get rooms" do
    get "/api/v1/rooms"
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["rooms"].is_a?(Array)
    assert json["rooms"].first["id"]
    assert json["rooms"].first["name"]
    assert json["rooms"].first["capacity"]
  end

  test "should get availability for available dates" do
    get "/api/v1/availability", params: { starts: "2030-01-01", ends: "2030-01-05" }
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["available"].is_a?(Array)
  end

  test "should return error when missing dates for availability" do
    get "/api/v1/availability"
    assert_response :bad_request

    json = JSON.parse(@response.body)
    assert_equal "Missing starts or ends parameter", json["error"]
  end

  test "should get bookings" do
    get "/api/v1/bookings"
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["bookings"].is_a?(Array)
  end

  test "should filter bookings by status active" do
    get "/api/v1/bookings", params: { status: "active" }
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["bookings"].is_a?(Array)
  end

  test "should filter bookings by status cancelled" do
    get "/api/v1/bookings", params: { status: "cancelled" }
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["bookings"].is_a?(Array)
  end

  test "should get single booking" do
    get "/api/v1/bookings/#{@booking.id}"
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["booking"]["id"]
    assert json["booking"]["name"]
    assert json["booking"]["room_name"]
    assert json["booking"]["adults"]
    assert json["booking"]["starts_at"]
    assert json["booking"]["ends_at"]
  end

  test "should return 404 for non-existent booking" do
    get "/api/v1/bookings/99999"
    assert_response :not_found

    json = JSON.parse(@response.body)
    assert_equal "Booking not found", json["error"]
  end

  test "should search guests by name" do
    get "/api/v1/guests", params: { search: "John" }
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["guests"].is_a?(Array)
  end

  test "should return error when missing search parameter for guests" do
    get "/api/v1/guests"
    assert_response :bad_request

    json = JSON.parse(@response.body)
    assert_equal "Missing search parameter", json["error"]
  end

  test "should create booking" do
    new_room = @account.properties.first.rooms.create!(
      name: "Test Room #{Time.now.to_i}",
      capacity: 2,
      price: 100
    )

    assert_difference("Booking.count", 1) do
      post "/api/v1/bookings", params: {
        room_id: new_room.id,
        name: "Test Guest",
        starts: Date.today + 30,
        ends: Date.today + 33,
        adults: 2,
        children: 0
      }
    end

    assert_response :created
    json = JSON.parse(@response.body)
    assert json["success"]
    assert_equal "Test Guest", json["booking"]["name"]
  end

  test "should update booking" do
    patch "/api/v1/bookings/#{@booking.id}", params: {
      name: "Updated Guest Name",
      adults: 3
    }

    assert_response :success
    json = JSON.parse(@response.body)
    assert json["success"]
    assert_equal "Updated Guest Name", json["booking"]["name"]
    assert_equal 3, json["booking"]["adults"]
  end

  test "should return error when creating booking with invalid room" do
    post "/api/v1/bookings", params: {
      room_id: 99999,
      name: "Test Guest",
      starts: Date.today + 30,
      ends: Date.today + 33
    }

    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert_equal "Room not found", json["error"]
  end

  test "should verify valid code" do
    # Create authorized user for the test account
    authorized_user = AuthorizedUser.create!(
      user: @user,
      account: @account,
      email_address: @user.email_address
    )

    verification = BotVerification.create!(
      chat_id: "123456",
      authorized_user: authorized_user
    )

    post "/api/v1/auth/verify", params: {
      chat_id: "123456",
      code: verification.code
    }

    assert_response :success
    json = JSON.parse(@response.body)
    assert json["success"]
    assert_equal @user.id, json["user"]["id"]
    assert_equal @user.name, json["user"]["name"]
  end

  test "should reject invalid code" do
    post "/api/v1/auth/verify", params: {
      chat_id: "123456",
      code: "000000"
    }

    assert_response :unauthorized
    json = JSON.parse(@response.body)
    refute json["success"]
    assert_equal "Invalid or expired code", json["error"]
  end

end
