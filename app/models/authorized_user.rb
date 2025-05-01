# frozen_string_literal: true

# == Schema Information
#
# Table name: authorized_users
#
#  id            :integer          not null, primary key
#  email_address :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :integer
#  user_id       :integer
#
# Indexes
#
#  index_authorized_users_on_account_id  (account_id)
#  index_authorized_users_on_user_id     (user_id)
#
class AuthorizedUser < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :account, optional: true

  validates :email_address, uniqueness: { case_sensitive: true }
end
