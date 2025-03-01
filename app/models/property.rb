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
class Property < ApplicationRecord

  belongs_to :account
  has_many :rooms, dependent: :destroy
  has_many :bookings, through: :rooms

  validates :name, presence: true, uniqueness: { scope: :account_id, message: :taken }

end
