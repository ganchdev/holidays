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
#  ends_at      :datetime
#  notes        :text
#  price        :decimal(10, 2)
#  starts_at    :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  room_id      :integer          not null
#
# Indexes
#
#  index_bookings_on_cancelled_at  (cancelled_at)
#  index_bookings_on_ends_at       (ends_at)
#  index_bookings_on_room_id       (room_id)
#  index_bookings_on_starts_at     (starts_at)
#
class Booking < ApplicationRecord

  belongs_to :room

  delegate :property, to: :room

  validates :adults, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :children, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validate :ends_at_after_starts_at
  validate :no_overlapping_bookings

  before_validation :transform_datetimes

  scope :active, -> { where(cancelled_at: nil) }
  scope :upcoming, -> { where("starts_at >= ?", Date.current.beginning_of_day + 1.day) }
  scope :past, -> { where("ends_at < ?", Date.current.beginning_of_day) }

  scope :overlapping, lambda { |starts_at, ends_at|
    where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
  }
  scope :for_day, lambda { |day|
    overlapping(day.to_date, day.to_date + 1)
  }

  def nights
    (ends_at.to_date - starts_at.to_date).to_i
  end

  def amount_due
    return 0.00 if price.zero?

    total = price * nights

    return 0.00 if total < deposit

    total - deposit
  end

  private

  def transform_datetimes
    self.starts_at = starts_at&.end_of_day
    self.ends_at = ends_at&.beginning_of_day
  end

  def ends_at_after_starts_at
    return if ends_at.blank? || starts_at.blank?

    return unless ends_at < starts_at

    errors.add(:ends_at, I18n.t("activerecord.errors.models.booking.attributes.ends_at.after_starts_at"))
  end

  def no_overlapping_bookings
    return if cancelled_at.present? || room_id.blank? || property.nil? || starts_at.blank? || ends_at.blank?

    overlapping_bookings = property.bookings
                                   .active
                                   .where(room_id: room_id)
                                   .where.not(id: id)
                                   .overlapping(starts_at, ends_at)

    return unless overlapping_bookings.exists?

    errors.add(:base, I18n.t("activerecord.errors.models.booking.attributes.base.overlapping_booking"))
  end

end
