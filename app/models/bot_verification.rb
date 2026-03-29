# frozen_string_literal: true

# == Schema Information
#
# Table name: bot_verifications
#
#  id                 :integer          not null, primary key
#  code               :string           not null
#  expires_at         :datetime         not null
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  authorized_user_id :integer          not null
#  chat_id            :string           not null
#
# Indexes
#
#  index_bot_verifications_on_authorized_user_id  (authorized_user_id)
#  index_bot_verifications_on_chat_id_and_code    (chat_id,code)
#  index_bot_verifications_on_token               (token) UNIQUE
#
# Foreign Keys
#
#  authorized_user_id  (authorized_user_id => authorized_users.id)
#
class BotVerification < ApplicationRecord

  belongs_to :authorized_user

  before_validation :generate_code, on: :create
  before_validation :generate_token, on: :create

  def self.find_by_code_and_chat_id(code, chat_id)
    verification = find_by(chat_id: chat_id, code: code)
    return nil unless verification

    if verification.expires_at > Time.current
      verification
    else
      verification.destroy
      nil
    end
  end

  def self.find_by_token(token)
    find_by(token: token)
  end

  private

  def generate_code
    self.code = SecureRandom.random_number(100000).to_s.rjust(6, "0")
    self.expires_at = 10.minutes.from_now
  end

  def generate_token
    self.token ||= SecureRandom.alphanumeric(32)
  end

end
