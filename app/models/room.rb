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

  scope :available_between, lambda { |start_date, end_date|
    where.not(id: joins(:bookings)
                  .where("bookings.starts_at < ? AND bookings.ends_at > ?",
                         end_date.to_datetime, start_date.to_datetime)
                  .select("rooms.id"))
  }

end
