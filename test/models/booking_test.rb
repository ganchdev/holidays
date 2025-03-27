# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id           :integer          not null, primary key
#  adults       :integer          default(1)
#  cancelled_at :datetime
#  children     :integer          default(0)
#  deposit      :decimal(10, 2)
#  ends_at      :datetime
#  notes        :text
#  starts_at    :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  room_id      :integer          not null
#
# Indexes
#
#  index_bookings_on_room_id  (room_id)
#
require "test_helper"

class BookingTest < ActiveSupport::TestCase

  def setup
    @booking = Booking.new(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:one),
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 5.days
    )
  end

  test "should be valid with all required attributes" do
    assert @booking.valid?
  end

  test "should require adults" do
    @booking.adults = nil
    assert_not @booking.valid?, "Saved the booking without adults"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.adults.blank",
                              default: "can't be blank")
    assert_includes @booking.errors[:adults], expected_message
  end

  test "should require adults to be at least 1" do
    @booking.adults = 0
    assert_not @booking.valid?, "Saved the booking with 0 adults"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.adults.greater_than_or_equal_to",
                              default: "must be at least 1")
    assert_includes @booking.errors[:adults], expected_message
  end

  test "should require adults to be an integer" do
    @booking.adults = 2.5
    assert_not @booking.valid?, "Saved the booking with a non-integer adults count"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.adults.not_an_integer",
                              default: "must be an integer")
    assert_includes @booking.errors[:adults], expected_message
  end

  test "should require children to be at least 0" do
    @booking.children = -1
    assert_not @booking.valid?, "Saved the booking with negative children"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.children.greater_than_or_equal_to",
                              default: "must be at least 0")
    assert_includes @booking.errors[:children], expected_message
  end

  test "should require children to be an integer" do
    @booking.children = 1.5
    assert_not @booking.valid?, "Saved the booking with a non-integer children count"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.children.not_an_integer",
                              default: "must be an integer")
    assert_includes @booking.errors[:children], expected_message
  end

  test "should require deposit to be at least 0" do
    @booking.deposit = -10
    assert_not @booking.valid?, "Saved the booking with a negative deposit"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.deposit.greater_than_or_equal_to",
                              default: "must be at least 0")
    assert_includes @booking.errors[:deposit], expected_message
  end

  test "should require deposit to be a number" do
    @booking.deposit = "abc"
    assert_not @booking.valid?, "Saved the booking with a non-numeric deposit"
    expected_message = I18n.t("activerecord.errors.models.booking.attributes.deposit.not_a_number",
                              default: "must be a number")
    assert_includes @booking.errors[:deposit], expected_message
  end

  test "should respond to room association" do
    assert_respond_to @booking, :room
  end

  test "for_day scope should return bookings that overlap with the specified day" do
    # Create a booking for days 10-15
    base_date = Date.today.beginning_of_month
    booking1 = Booking.create!(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:two), # Using a different room to avoid overlap validation
      starts_at: base_date + 10.days,
      ends_at: base_date + 15.days
    )

    # Create a booking that ends exactly at the start of day 16
    booking2 = Booking.create!(
      adults: 1,
      children: 0,
      deposit: 50.00,
      room: rooms(:three),
      starts_at: base_date + 12.days,
      ends_at: (base_date + 16.days).beginning_of_day
    )

    # Create a booking that starts exactly at the end of day 9
    booking3 = Booking.create!(
      adults: 3,
      children: 2,
      deposit: 150.00,
      room: rooms(:four),
      starts_at: (base_date + 9.days).end_of_day,
      ends_at: base_date + 14.days
    )

    # Create a booking completely outside the test range
    Booking.create!(
      adults: 2,
      children: 0,
      deposit: 75.00,
      room: rooms(:five),
      starts_at: base_date + 20.days,
      ends_at: base_date + 25.days
    )

    # Test various days
    day10 = base_date + 10.days
    day12 = base_date + 12.days
    day15 = base_date + 15.days
    day20 = base_date + 20.days

    # Day 10: should include booking1 and booking3
    assert_equal 2, Booking.for_day(day10).count
    assert_includes Booking.for_day(day10), booking1
    assert_includes Booking.for_day(day10), booking3

    # Day 12: should include booking1, booking2 and booking3
    assert_equal 3, Booking.for_day(day12).count
    assert_includes Booking.for_day(day12), booking1
    assert_includes Booking.for_day(day12), booking2
    assert_includes Booking.for_day(day12), booking3

    # Day 15: should include booking1 and booking2
    assert_equal 2, Booking.for_day(day15).count
    assert_includes Booking.for_day(day15), booking1
    assert_includes Booking.for_day(day15), booking2

    # Day 20: should include the booking outside our test range
    assert_equal 1, Booking.for_day(day20).count
    assert_not_includes Booking.for_day(day20), booking1
    assert_not_includes Booking.for_day(day20), booking2
    assert_not_includes Booking.for_day(day20), booking3
  end

  test "should not allow overlapping bookings for the same room" do # rubocop:disable Metrics/BlockLength
    @booking.save!

    @booking = Booking.new(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:one),
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 5.days
    )

    overlapping_booking = Booking.new(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:one),
      starts_at: @booking.starts_at + 1.day,
      ends_at: @booking.ends_at - 1.day
    )

    overlapping_booking_two = Booking.new(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:one),
      starts_at: @booking.starts_at - 1.day,
      ends_at: @booking.starts_at + 1.day
    )

    overlapping_booking_three = Booking.new(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:one),
      starts_at: @booking.ends_at - 1.day,
      ends_at: @booking.ends_at + 1.day
    )

    assert_not overlapping_booking.valid?, "Saved an overlapping booking"
    assert_not overlapping_booking_two.valid?, "Saved an overlapping booking"
    assert_not overlapping_booking_three.valid?, "Saved an overlapping booking"

    expected_message = I18n.t("activerecord.errors.models.booking.attributes.base.overlapping_booking",
                              default: "Booking times overlap with an existing booking")
    assert_includes overlapping_booking.errors[:base], expected_message
  end

end
