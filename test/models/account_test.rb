# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class AccountTest < ActiveSupport::TestCase

  def setup
    @account = Account.new(name: "Test Account")
  end

  test "should be valid with a name" do
    assert @account.valid?
  end

  test "should require a name" do
    @account.name = nil
    assert_not @account.valid?, "Saved the account without a name"
    expected_message = I18n.t("activerecord.errors.models.account.attributes.name.blank", default: "can't be blank")
    assert_includes @account.errors[:name], expected_message
  end

  test "should have a unique name" do
    existing_account = accounts(:one)
    @account.name = existing_account.name

    assert_not @account.valid?, "Saved the account with a duplicate name"
    expected_message = I18n.t("activerecord.errors.models.account.attributes.name.taken",
                              default: "has already been taken")
    assert_includes @account.errors[:name], expected_message
  end

  test "should respond to users association" do
    assert_respond_to @account, :users
  end

  test "should respond to properties association" do
    assert_respond_to @account, :properties
  end

end
