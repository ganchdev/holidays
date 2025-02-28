# frozen_string_literal: true

# == Schema Information
#
# Table name: properties
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#
# Indexes
#
#  index_properties_on_account_id  (account_id)
#
require "test_helper"

class PropertyTest < ActiveSupport::TestCase

  def setup
    @property = Property.new(name: "Test Property", account: accounts(:one))
  end

  test "should be valid with all required attributes" do
    assert @property.valid?
  end

  test "should require a name" do
    @property.name = nil
    assert_not @property.valid?, "Saved the property without a name"
    expected_message = I18n.t("activerecord.errors.models.property.attributes.name.blank", default: "can't be blank")
    assert_includes @property.errors[:name], expected_message
  end

  test "should require an account" do
    @property.account = nil
    assert_not @property.valid?, "Saved the property without an account"
    expected_message = I18n.t("activerecord.errors.models.property.attributes.account.blank",
                              default: "must be associated with an account")
    assert_includes @property.errors[:account], expected_message
  end

  test "should respond to account association" do
    assert_respond_to @property, :account
  end

  test "should respond to rooms association" do
    assert_respond_to @property, :rooms
  end

  test "should have many rooms" do
    assert_equal 0, @property.rooms.size, "Property should have no rooms initially"

    room = Room.new(name: "Test Room", property: @property)
    @property.rooms << room

    assert_equal 1, @property.rooms.size, "Property should have one room after adding"
    assert_includes @property.rooms, room, "Property should include the added room"
  end

  test "should destroy associated rooms when property is destroyed" do
    @property.save!
    room = Room.create!(name: "Test Room", capacity: 2, property: @property)

    assert_difference("Room.count", -1) do
      @property.destroy
    end

    assert_raises(ActiveRecord::RecordNotFound) { room.reload }
  end

  test "should not save property with a duplicate name within the same account" do
    @property.save!
    duplicate_property = Property.new(name: "Test Property", account: accounts(:one))

    assert_not duplicate_property.valid?, "Saved the property with a duplicate name within the same account"
    expected_message = I18n.t("activerecord.errors.models.property.attributes.name.taken",
                              default: "must be unique within the account")
    assert_includes duplicate_property.errors[:name], expected_message
  end

  test "should save property with the same name in different accounts" do
    @property.save!
    other_account_property = Property.new(name: "Test Property", account: accounts(:two))

    assert other_account_property.valid?, "Failed to save property with the same name in a different account"
  end

end
