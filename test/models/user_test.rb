# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  admin         :boolean
#  email_address :string           not null
#  first_name    :string
#  image         :string
#  last_name     :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :integer
#
# Indexes
#
#  index_users_on_account_id     (account_id)
#  index_users_on_email_address  (email_address) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(
      name: "John Doe",
      email_address: "john@example.com",
      first_name: "John",
      last_name: "Doe"
    )
  end

  test "should be valid with all required attributes" do
    assert @user.valid?
  end

  test "should require a name" do
    @user.name = nil
    assert_not @user.valid?, "Saved the user without a name"
    expected_message = I18n.t("activerecord.errors.models.user.attributes.name.blank", default: "can't be blank")
    assert_includes @user.errors[:name], expected_message
  end

  test "should require an email address" do
    @user.email_address = nil
    assert_not @user.valid?, "Saved the user without an email address"
    expected_message = I18n.t("activerecord.errors.models.user.attributes.email_address.blank",
                              default: "can't be blank")
    assert_includes @user.errors[:email_address], expected_message
  end

  test "should require a first name" do
    @user.first_name = nil
    assert_not @user.valid?, "Saved the user without a first name"
    expected_message = I18n.t("activerecord.errors.models.user.attributes.first_name.blank", default: "can't be blank")
    assert_includes @user.errors[:first_name], expected_message
  end

  test "should require a last name" do
    @user.last_name = nil
    assert_not @user.valid?, "Saved the user without a last name"
    expected_message = I18n.t("activerecord.errors.models.user.attributes.last_name.blank", default: "can't be blank")
    assert_includes @user.errors[:last_name], expected_message
  end

  test "should require a unique email address" do
    existing_user = users(:one) # Assuming you have a fixture named :one
    @user.email_address = existing_user.email_address

    assert_not @user.valid?, "Saved the user with a duplicate email address"
    expected_message = I18n.t("activerecord.errors.models.user.attributes.email_address.taken",
                              default: "has already been taken")
    assert_includes @user.errors[:email_address], expected_message
  end

  test "should validate email format" do
    @user.email_address = "invalid-email"
    assert_not @user.valid?, "Saved the user with an invalid email address"
    expected_message = I18n.t("activerecord.errors.models.user.attributes.email_address.invalid", default: "is invalid")
    assert_includes @user.errors[:email_address], expected_message
  end

  test "should respond to account association" do
    assert_respond_to @user, :account
  end

  test "should respond to sessions association" do
    assert_respond_to @user, :sessions
  end

end
