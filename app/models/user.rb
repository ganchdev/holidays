# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  admin           :boolean
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :integer          not null
#
# Indexes
#
#  index_users_on_account_id     (account_id)
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord

  belongs_to :account

  has_many :sessions, dependent: :destroy
  has_secure_password

  normalizes :email_address, with: -> (e) { e.strip.downcase }

end
