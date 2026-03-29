# frozen_string_literal: true

require "test_helper"

class BotApiControllerTest < ActionDispatch::IntegrationTest

  setup do
    @account = accounts(:one)
    @user = users(:one)
    @authorized_user = authorized_users(:one)
    @property = properties(:one)
    @room = rooms(:one)
    @booking = bookings(:one)

    @token = nil
  end

  def get_token
    verification = BotVerification.create!(
      chat_id: "123456#{Time.now.to_i}",
      authorized_user: @authorized_user
    )
    verification.token
  end

  def auth_headers
    { "Authorization" => "Bearer #{@token}" }
  end

  test "should reject requests without token" do
    get "/api/v1/rooms"
    assert_response :unauthorized

    json = JSON.parse(@response.body)
    assert_equal "Missing token", json["error"]
  end

  test "should reject requests with invalid token" do
    get "/api/v1/rooms", headers: { "Authorization" => "Bearer invalid" }
    assert_response :unauthorized

    json = JSON.parse(@response.body)
    assert_equal "Invalid token", json["error"]
  end

  test "should verify valid code and return token" do
    verification = BotVerification.create!(
      chat_id: "123456#{Time.now.to_i}",
      authorized_user: @authorized_user
    )

    post "/api/v1/auth/verify", params: {
      chat_id: verification.chat_id,
      code: verification.code
    }

    assert_response :success
    json = JSON.parse(@response.body)
    assert json["success"]
    assert json["token"]
    assert_equal @user.email_address, json["user"]["email"]
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

  test "should get rooms with valid token" do
    @token = get_token

    get "/api/v1/rooms", headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["rooms"].is_a?(Array)
  end

  test "should get availability with valid token" do
    @token = get_token

    get "/api/v1/availability", params: { starts: "2030-01-01", ends: "2030-01-05" }, headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["available"].is_a?(Array)
  end

  test "should return error when missing dates for availability" do
    @token = get_token

    get "/api/v1/availability", headers: auth_headers
    assert_response :bad_request

    json = JSON.parse(@response.body)
    assert_equal "Missing starts or ends parameter", json["error"]
  end

  test "should get bookings with valid token" do
    @token = get_token

    get "/api/v1/bookings", headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["bookings"].is_a?(Array)
  end

  test "should filter bookings by status active with valid token" do
    @token = get_token

    get "/api/v1/bookings", params: { status: "active" }, headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["bookings"].is_a?(Array)
  end

  test "should filter bookings by status cancelled with valid token" do
    @token = get_token

    get "/api/v1/bookings", params: { status: "cancelled" }, headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["bookings"].is_a?(Array)
  end

  test "should get single booking with valid token" do
    @token = get_token

    get "/api/v1/bookings/#{@booking.id}", headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["booking"]["id"]
    assert json["booking"]["name"]
  end

  test "should return 404 for non-existent booking with valid token" do
    @token = get_token

    get "/api/v1/bookings/999999", headers: auth_headers
    assert_response :not_found

    json = JSON.parse(@response.body)
    assert_equal "Booking not found", json["error"]
  end

  test "should search guests by name with valid token" do
    @token = get_token

    get "/api/v1/guests", params: { search: "Test" }, headers: auth_headers
    assert_response :success

    json = JSON.parse(@response.body)
    assert json["guests"].is_a?(Array)
  end

  test "should return error when missing search parameter for guests with valid token" do
    @token = get_token

    get "/api/v1/guests", headers: auth_headers
    assert_response :bad_request

    json = JSON.parse(@response.body)
    assert_equal "Missing search parameter", json["error"]
  end

  test "should create booking with valid token" do
    @token = get_token

    new_room = Room.create!(
      property: @property,
      name: "New Room #{SecureRandom.hex(4)}",
      capacity: 2,
      price: 100
    )

    assert_difference("Booking.count", 1) do
      post "/api/v1/bookings",
           params: {
             room_id: new_room.id,
             name: "New Guest",
             starts: Date.today + 30,
             ends: Date.today + 33,
             adults: 2,
             children: 0
           },
           headers: auth_headers
    end

    assert_response :created
    json = JSON.parse(@response.body)
    assert json["success"]
    assert_equal "New Guest", json["booking"]["name"]
  end

  test "should update booking with valid token" do
    @token = get_token

    patch "/api/v1/bookings/#{@booking.id}",
          params: {
            name: "Updated Guest Name",
            adults: 3
          },
          headers: auth_headers

    assert_response :success
    json = JSON.parse(@response.body)
    assert json["success"]
    assert_equal "Updated Guest Name", json["booking"]["name"]
    assert_equal 3, json["booking"]["adults"]
  end

  test "should return error when creating booking with invalid room and valid token" do
    @token = get_token

    post "/api/v1/bookings",
         params: {
           room_id: 999_999,
           name: "Test Guest",
           starts: Date.today + 30,
           ends: Date.today + 33
         },
         headers: auth_headers

    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert_equal "Room not found", json["error"]
  end

end
