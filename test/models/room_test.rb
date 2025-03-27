# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :integer          not null, primary key
#  capacity    :integer
#  color       :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  property_id :integer          not null
#
# Indexes
#
#  index_rooms_on_property_id  (property_id)
#
require "test_helper"

class RoomTest < ActiveSupport::TestCase

  def setup
    @room = Room.new(name: "Conference Room", capacity: 10, property: properties(:one)) # Using a fixture for property
    @booking = bookings(:one)
  end

  test "should be valid with all required attributes" do
    assert @room.valid?
  end

  test "should require a name" do
    @room.name = nil
    assert_not @room.valid?, "Saved the room without a name"
    expected_message = I18n.t("activerecord.errors.models.room.attributes.name.blank", default: "can't be blank")
    assert_includes @room.errors[:name], expected_message
  end

  test "should require a capacity" do
    @room.capacity = nil
    assert_not @room.valid?, "Saved the room without a capacity"
    expected_message = I18n.t("activerecord.errors.models.room.attributes.capacity.blank", default: "can't be blank")
    assert_includes @room.errors[:capacity], expected_message
  end

  test "should require capacity to be a positive number" do
    @room.capacity = -1
    assert_not @room.valid?, "Saved the room with a negative capacity"
    expected_message = I18n.t("activerecord.errors.models.room.attributes.capacity.greater_than",
                              default: "must be greater than 0")
    assert_includes @room.errors[:capacity], expected_message
  end

  test "should require capacity to be an integer" do
    @room.capacity = 2.5
    assert_not @room.valid?, "Saved the room with a non-integer capacity"
    expected_message = I18n.t("activerecord.errors.models.room.attributes.capacity.not_an_integer",
                              default: "must be an integer")
    assert_includes @room.errors[:capacity], expected_message
  end

  test "should respond to property association" do
    assert_respond_to @room, :property
  end

  test "should not destroy room with existing bookings" do
    @booking.update(room: @room)

    assert_no_difference("Room.count") do
      @room.destroy
    end

    assert @room.errors[:base].include?(
      I18n.t("activerecord.errors.models.room.restrict_dependent_destroy.has_many", record: "bookings")
    ), "Expected room to have an error preventing destruction when bookings exist"
  end

  test "should destroy room if no bookings exist" do
    @booking.update(room: @room)

    @room.bookings.destroy_all

    assert_difference("Room.count", -1) do
      @room.destroy
    end
  end

  test "should find rooms available between dates" do
    # Setup: Create rooms
    room1 = Room.create!(name: "Odd Room", capacity: 5, property: properties(:one))
    room2 = Room.create!(name: "Meeting Room", capacity: 5, property: properties(:one))
    room3 = Room.create!(name: "Board Room", capacity: 20, property: properties(:one))

    # Room 1: Booking Jan 5-8 (check-in Jan 5, check-out Jan 8)
    Booking.create!(
      room: room1,
      starts_at: Date.new(2023, 1, 5),  # Check-in
      ends_at: Date.new(2023, 1, 8)     # Check-out
    )

    # Room 2: Booking Jan 10-15
    Booking.create!(
      room: room2,
      starts_at: Date.new(2023, 1, 10),
      ends_at: Date.new(2023, 1, 15)
    )

    # Room 3: Two bookings: Jan 3-6 and Jan 20-25
    Booking.create!(
      room: room3,
      starts_at: Date.new(2023, 1, 3),
      ends_at: Date.new(2023, 1, 6)
    )

    Booking.create!(
      room: room3,
      starts_at: Date.new(2023, 1, 20),
      ends_at: Date.new(2023, 1, 25)
    )

    # Test Case 1: Jan 1-3 (check-in Jan 1, check-out Jan 3)
    # Room 3 has check-in on Jan 3, so it SHOULD be in the results
    # because the guest from Jan 1-3 checks out before the new guest checks in
    available_rooms = Room.available_between(
      Date.new(2023, 1, 1),
      Date.new(2023, 1, 3)
    )
    assert_includes available_rooms, room1, "Room1 should be available Jan 1-3"
    assert_includes available_rooms, room2, "Room2 should be available Jan 1-3"
    assert_includes available_rooms, room3, "Room3 should be available Jan 1-3 (new booking starts on check-out date)"

    # Test Case 2: Jan 3-6 (exact overlap with room3 booking)
    available_rooms = Room.available_between(
      Date.new(2023, 1, 3),
      Date.new(2023, 1, 6)
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available Jan 3-6"
    assert_includes available_rooms, room2, "Room2 should be available Jan 3-6"
    assert_not_includes available_rooms, room3, "Room3 should not be available Jan 3-6 (exact booking dates)"

    # Test Case 3: Jan 6-10 (between two bookings for room3)
    available_rooms = Room.available_between(
      Date.new(2023, 1, 6),
      Date.new(2023, 1, 10)
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available Jan 6-10 (overlaps with Jan 5-8 booking)"
    assert_includes available_rooms, room2, "Room2 should be available Jan 6-10 (new booking starts on check-out date)"
    assert_includes available_rooms, room3, "Room3 should be available Jan 6-10 (between bookings)"

    # Test Case 4: Jan 8-10 (room1 booking ends on Jan 8)
    available_rooms = Room.available_between(
      Date.new(2023, 1, 8),
      Date.new(2023, 1, 10)
    )
    assert_includes available_rooms, room1, "Room1 should be available Jan 8-10 (previous booking check-out is Jan 8)"
    assert_includes available_rooms, room2, "Room2 should be available Jan 8-10 (next booking check-in is Jan 10)"
    assert_includes available_rooms, room3, "Room3 should be available Jan 8-10"

    # Test Case 5: Booking that spans multiple existing bookings
    available_rooms = Room.available_between(
      Date.new(2023, 1, 4),
      Date.new(2023, 1, 12)
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available Jan 4-12 (overlaps with booking)"
    assert_not_includes available_rooms, room2, "Room2 should not be available Jan 4-12 (overlaps with booking)"
    assert_not_includes available_rooms, room3, "Room3 should not be available Jan 4-12 (overlaps with booking)"

    # Test Case 6: Testing start date = existing end date
    available_rooms = Room.available_between(
      Date.new(2023, 1, 8), # Room1's check-out date
      Date.new(2023, 1, 12)
    )
    assert_includes available_rooms, room1, "Room1 should be available when search starts on check-out date"
    assert_not_includes available_rooms, room2, "Room2 should not be available (overlaps with Jan 10 check-in)"
    assert_includes available_rooms, room3, "Room3 should be available Jan 8-12"

    # Test Case 7: Testing end date = existing start date
    available_rooms = Room.available_between(
      Date.new(2023, 1, 6),
      Date.new(2023, 1, 10) # Room2's check-in date
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available (overlaps with booking)"
    assert_includes available_rooms, room2, "Room2 should be available when search ends on check-in date"
    assert_includes available_rooms, room3, "Room3 should be available Jan 6-10"
  end

end
