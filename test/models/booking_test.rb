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
