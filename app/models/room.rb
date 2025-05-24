# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :integer          not null, primary key
#  capacity    :integer
#  color       :string
#  name        :string
#  price       :decimal(10, 2)
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

  validates :name, presence: true, uniqueness: { scope: :property_id, message: :taken }
  validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :available_between, lambda { |starts_at, ends_at|
    where.not(id: joins(:bookings)
              .where("bookings.starts_at < ? AND bookings.ends_at > ? AND bookings.cancelled_at IS NULL",
                     ends_at, starts_at&.end_of_day)
              .select("rooms.id"))
  }

  scope :available_for_booking, lambda { |booking|
    available = available_between(booking.starts_at, booking.ends_at)
    room_with_booking = joins(:bookings).where(
      "bookings.starts_at < ? AND bookings.ends_at > ? AND bookings.id = ? AND bookings.cancelled_at IS NULL",
      booking.ends_at, booking.starts_at.end_of_day, booking.id
    ).select("rooms.id")

    where(id: available).or(where(id: room_with_booking))
  }

end
