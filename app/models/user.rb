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
class User < ApplicationRecord

  belongs_to :account, optional: true
  has_many :sessions, dependent: :destroy

  validates :name, :email_address, :first_name, :last_name, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: true }

end
