# frozen_string_literal: true

# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  adults       :integer          default(1)
#  cancelled_at :datetime
#  children     :integer          default(0)
#  deposit      :decimal(10, 2)
#  notes        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  room_id      :integer          not null
#
# Indexes
#
#  index_reservations_on_room_id  (room_id)
#
require "test_helper"

class ReservationTest < ActiveSupport::TestCase

  def setup
    @reservation = Reservation.new(
      adults: 2,
      children: 1,
      deposit: 100.50,
      room: rooms(:one) # Using fixture for room
    )
  end

  test "should be valid with all required attributes" do
    assert @reservation.valid?
  end

  test "should require adults" do
    @reservation.adults = nil
    assert_not @reservation.valid?, "Saved the reservation without adults"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.adults.blank",
                              default: "can't be blank")
    assert_includes @reservation.errors[:adults], expected_message
  end

  test "should require adults to be at least 1" do
    @reservation.adults = 0
    assert_not @reservation.valid?, "Saved the reservation with 0 adults"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.adults.greater_than_or_equal_to",
                              default: "must be at least 1")
    assert_includes @reservation.errors[:adults], expected_message
  end

  test "should require adults to be an integer" do
    @reservation.adults = 2.5
    assert_not @reservation.valid?, "Saved the reservation with a non-integer adults count"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.adults.not_an_integer",
                              default: "must be an integer")
    assert_includes @reservation.errors[:adults], expected_message
  end

  test "should require children to be at least 0" do
    @reservation.children = -1
    assert_not @reservation.valid?, "Saved the reservation with negative children"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.children.greater_than_or_equal_to",
                              default: "must be at least 0")
    assert_includes @reservation.errors[:children], expected_message
  end

  test "should require children to be an integer" do
    @reservation.children = 1.5
    assert_not @reservation.valid?, "Saved the reservation with a non-integer children count"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.children.not_an_integer",
                              default: "must be an integer")
    assert_includes @reservation.errors[:children], expected_message
  end

  test "should require deposit to be at least 0" do
    @reservation.deposit = -10
    assert_not @reservation.valid?, "Saved the reservation with a negative deposit"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.deposit.greater_than_or_equal_to",
                              default: "must be at least 0")
    assert_includes @reservation.errors[:deposit], expected_message
  end

  test "should require deposit to be a number" do
    @reservation.deposit = "abc"
    assert_not @reservation.valid?, "Saved the reservation with a non-numeric deposit"
    expected_message = I18n.t("activerecord.errors.models.reservation.attributes.deposit.not_a_number",
                              default: "must be a number")
    assert_includes @reservation.errors[:deposit], expected_message
  end

  test "should respond to room association" do
    assert_respond_to @reservation, :room
  end

end
