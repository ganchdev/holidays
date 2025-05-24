# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :integer          not null, primary key
#  capacity    :integer
#  color       :string
#  name        :string
#  price       :decimal(10, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  property_id :integer          not null
#
# Indexes
#
#  index_rooms_on_property_id  (property_id)
#
require "test_helper"

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ClassLength
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

  test "should have a unique name" do
    existing_room = rooms(:one)
    @room.name = existing_room.name

    assert_not @room.valid?, "Saved the room with a duplicate name"
    expected_message = I18n.t("activerecord.errors.models.room.attributes.name.taken",
                              default: "has already been taken")
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

  # Room.available_between
  test "should find rooms available between dates" do
    # Setup: Create rooms
    room1 = Room.create!(name: "Odd Room", capacity: 5, property: properties(:one))
    room2 = Room.create!(name: "Meeting Room", capacity: 5, property: properties(:one))
    room3 = Room.create!(name: "Board Room", capacity: 20, property: properties(:one))

    # Room 1: Booking Jan 5-8 (check-in Jan 5, check-out Jan 8)
    Booking.create!(
      room: room1,
      starts_at: Date.new(2025, 1, 5),  # Check-in
      ends_at: Date.new(2025, 1, 8)     # Check-out
    )

    # Room 2: Booking Jan 10-15
    Booking.create!(
      room: room2,
      starts_at: Date.new(2025, 1, 10),
      ends_at: Date.new(2025, 1, 15)
    )

    # Room 3: Two bookings: Jan 3-6 and Jan 20-25
    Booking.create!(
      room: room3,
      starts_at: Date.new(2025, 1, 3),
      ends_at: Date.new(2025, 1, 6)
    )

    Booking.create!(
      room: room3,
      starts_at: Date.new(2025, 1, 20),
      ends_at: Date.new(2025, 1, 25)
    )

    # Test Case 1: Jan 1-3 (check-in Jan 1, check-out Jan 3)
    # Room 3 has check-in on Jan 3, so it SHOULD be in the results
    # because the guest from Jan 1-3 checks out before the new guest checks in
    available_rooms = Room.available_between(
      Date.new(2025, 1, 1),
      Date.new(2025, 1, 3)
    )
    assert_includes available_rooms, room1, "Room1 should be available Jan 1-3"
    assert_includes available_rooms, room2, "Room2 should be available Jan 1-3"
    assert_includes available_rooms, room3, "Room3 should be available Jan 1-3 (new booking starts on check-out date)"

    # Test Case 2: Jan 3-6 (exact overlap with room3 booking)
    available_rooms = Room.available_between(
      Date.new(2025, 1, 3),
      Date.new(2025, 1, 6)
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available Jan 3-6"
    assert_includes available_rooms, room2, "Room2 should be available Jan 3-6"
    assert_not_includes available_rooms, room3, "Room3 should not be available Jan 3-6 (exact booking dates)"

    # Test Case 3: Jan 6-10 (between two bookings for room3)
    available_rooms = Room.available_between(
      Date.new(2025, 1, 6),
      Date.new(2025, 1, 10)
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available Jan 6-10 (overlaps with Jan 5-8 booking)"
    assert_includes available_rooms, room2, "Room2 should be available Jan 6-10 (new booking starts on check-out date)"
    assert_includes available_rooms, room3, "Room3 should be available Jan 6-10 (between bookings)"

    # Test Case 4: Jan 8-10 (room1 booking ends on Jan 8)
    available_rooms = Room.available_between(
      Date.new(2025, 1, 8),
      Date.new(2025, 1, 10)
    )
    assert_includes available_rooms, room1, "Room1 should be available Jan 8-10 (previous booking check-out is Jan 8)"
    assert_includes available_rooms, room2, "Room2 should be available Jan 8-10 (next booking check-in is Jan 10)"
    assert_includes available_rooms, room3, "Room3 should be available Jan 8-10"

    # Test Case 5: Booking that spans multiple existing bookings
    available_rooms = Room.available_between(
      Date.new(2025, 1, 4),
      Date.new(2025, 1, 12)
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available Jan 4-12 (overlaps with booking)"
    assert_not_includes available_rooms, room2, "Room2 should not be available Jan 4-12 (overlaps with booking)"
    assert_not_includes available_rooms, room3, "Room3 should not be available Jan 4-12 (overlaps with booking)"

    # Test Case 6: Testing start date = existing end date
    available_rooms = Room.available_between(
      Date.new(2025, 1, 8), # Room1's check-out date
      Date.new(2025, 1, 12)
    )
    assert_includes available_rooms, room1, "Room1 should be available when search starts on check-out date"
    assert_not_includes available_rooms, room2, "Room2 should not be available (overlaps with Jan 10 check-in)"
    assert_includes available_rooms, room3, "Room3 should be available Jan 8-12"

    # Test Case 7: Testing end date = existing start date
    available_rooms = Room.available_between(
      Date.new(2025, 1, 6),
      Date.new(2025, 1, 10) # Room2's check-in date
    )
    assert_not_includes available_rooms, room1, "Room1 should not be available (overlaps with booking)"
    assert_includes available_rooms, room2, "Room2 should be available when search ends on check-in date"
    assert_includes available_rooms, room3, "Room3 should be available Jan 6-10"
  end

  test "should ignore cancelled bookings when checking availability between dates" do
    room = Room.create!(name: "Room A", capacity: 2, property: properties(:one))

    # Normal booking Jan 5–10
    Booking.create!(
      room: room,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10)
    )

    # Booking overlaps Jan 6–8, so not available
    unavailable = Room.available_between(Date.new(2025, 1, 6), Date.new(2025, 1, 8))
    assert_not_includes unavailable, room, "Room should not be available (active booking present)"

    # Cancel the booking
    room.bookings.first.update!(cancelled_at: Time.current)

    # Now it should be available
    available = Room.available_between(Date.new(2025, 1, 6), Date.new(2025, 1, 8))
    assert_includes available, room, "Room should be available after booking cancellation"
  end

  # Room.available_for_booking
  test "should include booked room and only other rooms available for the same period" do
    room1 = Room.create!(name: "Room 1", capacity: 5, property: properties(:one))
    room2 = Room.create!(name: "Room 2", capacity: 10, property: properties(:one))
    room3 = Room.create!(name: "Room 3", capacity: 15, property: properties(:one))
    room4 = Room.create!(name: "Room 4", capacity: 8, property: properties(:one))
    room5 = Room.create!(name: "Room 5", capacity: 2, property: properties(:one))

    # Bookings:
    # booking_a: Jan 5–10 on room1
    booking_a = Booking.create!(
      room: room1,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10)
    )

    # room2 has a conflicting booking Jan 7–9
    Booking.create!(
      room: room2,
      starts_at: Date.new(2025, 1, 7),
      ends_at: Date.new(2025, 1, 9)
    )

    # room3 has a non-overlapping booking Jan 2–4
    Booking.create!(
      room: room3,
      starts_at: Date.new(2025, 1, 2),
      ends_at: Date.new(2025, 1, 4)
    )

    # room4 has overlapping booking Jan 1–15 (completely blocks)
    Booking.create!(
      room: room4,
      starts_at: Date.new(2025, 1, 1),
      ends_at: Date.new(2025, 1, 15)
    )

    # room5 has overlapping Jan 15-20
    Booking.create!(
      room: room5,
      starts_at: Date.new(2025, 1, 19),
      ends_at: Date.new(2025, 1, 23)
    )

    # Case 1: Booking is Jan 5–10
    # We expect:
    # - room1 (current booking's room) to be included even if it overlaps
    # - room3 to be included (free during range)
    # - room2 & room4 to be excluded (conflict)
    available_rooms = Room.available_for_booking(booking_a)
    assert_includes available_rooms, room1, "Room1 should be included (it's the booking's own room)"
    assert_includes available_rooms, room3, "Room3 should be included (available Jan 5–10)"
    assert_not_includes available_rooms, room2, "Room2 should be excluded (overlaps Jan 7–9)"
    assert_not_includes available_rooms, room4, "Room4 should be excluded (completely booked)"

    # Case 2: Modify booking_a to Jan 3–6 (still within room3’s free time)
    booking_a.update!(starts_at: Date.new(2025, 1, 3), ends_at: Date.new(2025, 1, 6))
    available_rooms = Room.available_for_booking(booking_a)
    assert_includes available_rooms, room1, "Room1 should still be included"
    assert_not_includes available_rooms, room3, "Room3 should be excluded now (has booking Jan 2–4 overlapping)"

    # Case 3: booking completely isolated (Jan 20–25)
    booking_a.update!(starts_at: Date.new(2025, 1, 20), ends_at: Date.new(2025, 1, 25))
    available_rooms = Room.available_for_booking(booking_a)
    assert_includes available_rooms, room1, "Room1 should always be included"
    assert_includes available_rooms, room2, "Room2 should be included (no booking conflict)"
    assert_includes available_rooms, room3, "Room3 should be included (no conflict)"
    assert_includes available_rooms, room4, "Room4 should be included Jan 1–15"
    assert_not_includes available_rooms, room5, "Room5 should not be included"

    # Case 4: booking period exactly matches another booking on another room
    Booking.create!(
      room: room2,
      starts_at: Date.new(2025, 2, 1),
      ends_at: Date.new(2025, 2, 5)
    )
    booking_a.update!(starts_at: Date.new(2025, 2, 1), ends_at: Date.new(2025, 2, 5))
    available_rooms = Room.available_for_booking(booking_a)
    assert_includes available_rooms, room1, "Room1 always included"
    assert_not_includes available_rooms, room2, "Room2 has exact conflict, should be excluded"
  end

  test "cancelled conflicting booking should not prevent room from being available" do
    room1 = Room.create!(name: "Room 1", capacity: 2, property: properties(:one))
    room2 = Room.create!(name: "Room 2", capacity: 2, property: properties(:one))

    # Room1 has a booking in the range but it's cancelled
    Booking.create!(
      room: room1,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10),
      cancelled_at: Time.current
    )

    # Room2 has a real booking (not cancelled)
    Booking.create!(
      room: room2,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10)
    )

    booking = Booking.create!(
      room: room1,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10)
    )

    available_rooms = Room.available_for_booking(booking)
    assert_includes available_rooms, room1, "Room1 should be included (conflict is cancelled)"
    assert_not_includes available_rooms, room2, "Room2 should be excluded (active booking conflict)"
  end

  test "should not include cancelled booking on a different room" do
    room1 = Room.create!(name: "Main Room", capacity: 2, property: properties(:one))
    room2 = Room.create!(name: "Other Room", capacity: 2, property: properties(:one))

    # Cancelled booking on other room
    Booking.create!(
      room: room2,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10),
      cancelled_at: Time.current
    )

    # Booking on room1 (active)
    booking = Booking.create!(
      room: room1,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10)
    )

    available_rooms = Room.available_for_booking(booking)
    assert_includes available_rooms, room1, "Booking's own room should be included"
    assert_includes available_rooms, room2, "Room2 should be included (booking is cancelled)"
  end

  test "cancelled booking's room should be treated as available" do
    room = Room.create!(name: "Cancelled Room", capacity: 2, property: properties(:one))

    # This booking is cancelled
    booking = Booking.create!(
      room: room,
      starts_at: Date.new(2025, 1, 5),
      ends_at: Date.new(2025, 1, 10),
      cancelled_at: Time.current
    )

    available_rooms = Room.available_for_booking(booking)

    assert_includes available_rooms, room, "Cancelled booking's room should be available"
  end

end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ClassLength
