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
    @property = Property.new(name: "Test Property", account: accounts(:one)) # Using fixture for account
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

end
