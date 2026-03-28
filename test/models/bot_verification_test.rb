# frozen_string_literal: true

require "test_helper"

class BotVerificationTest < ActiveSupport::TestCase

  setup do
    @authorized_user = authorized_users(:one)
  end

  test "should generate 6-digit code on create" do
    verification = BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")

    assert_equal 6, verification.code.length
    assert verification.code.match?(/^\d{6}$/)
  end

  test "should set expires_at to 10 minutes from now on create" do
    verification = BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")

    assert_in_delta 10.minutes.from_now, verification.expires_at, 1.second
  end

  test "should find valid verification by code and chat_id" do
    verification = BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")

    found = BotVerification.find_by_code_and_chat_id(verification.code, "123456")

    assert_equal verification, found
  end

  test "should not find verification with wrong code" do
    BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")

    found = BotVerification.find_by_code_and_chat_id("000000", "123456")

    assert_nil found
  end

  test "should not find verification with wrong chat_id" do
    BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")

    verification = BotVerification.find_by(chat_id: "123456")
    found = BotVerification.find_by_code_and_chat_id(verification.code, "wrong_chat")

    assert_nil found
  end

  test "should not find expired verification and should destroy it" do
    expired = BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")
    expired.update!(expires_at: 1.hour.ago)

    found = BotVerification.find_by_code_and_chat_id(expired.code, "123456")

    assert_nil found
    assert_nil BotVerification.find_by(id: expired.id)
  end

  test "should belong to authorized_user" do
    verification = BotVerification.create!(authorized_user: @authorized_user, chat_id: "123456")

    assert_equal @authorized_user, verification.authorized_user
  end

end
