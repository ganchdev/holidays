# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id           :integer          not null, primary key
#  adults       :integer          default(1)
#  cancelled_at :datetime
#  children     :integer          default(0)
#  deposit      :decimal(10, 2)
#  notes        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  room_id      :integer          not null
#
# Indexes
#
#  index_bookings_on_room_id  (room_id)
#
class Booking < ApplicationRecord

  belongs_to :room

  validates :adults, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :children, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

end
