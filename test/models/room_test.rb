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

end
