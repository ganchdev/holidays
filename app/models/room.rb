# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :integer          not null, primary key
#  capacity    :integer
#  color       :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  property_id :integer          not null
#
# Indexes
#
#  index_rooms_on_property_id  (property_id)
#
class Room < ApplicationRecord

  belongs_to :property
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }

end
