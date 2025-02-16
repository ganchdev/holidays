# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  admin           :boolean
#  email_address   :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :integer          not null
#
# Indexes
#
#  index_users_on_account_id  (account_id)
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
