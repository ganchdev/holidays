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
#  starts_at    :datetime
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

  delegate :property, to: :room

  validates :adults, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :children, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validate :ends_at_after_starts_at
  validate :no_overlapping_bookings

  scope :upcoming, -> { where("starts_at >= ?", Date.current.beginning_of_day + 1.day) }
  scope :past, -> { where("ends_at < ?", Date.current.beginning_of_day) }
  scope :current, lambda {
    where("starts_at < ? AND ends_at >= ?", Date.current.beginning_of_day + 1.day, Date.current.beginning_of_day)
  }
  scope :for_day, lambda { |day|
    where("starts_at < ? AND ends_at > ?", day.to_date + 1, day.to_date)
  }

  private

  def ends_at_after_starts_at
    return if ends_at.blank? || starts_at.blank?

    return unless ends_at < starts_at

    errors.add(:ends_at, I18n.t("activerecord.errors.models.booking.attributes.ends_at.after_starts_at"))
  end

  def no_overlapping_bookings
    return if room_id.blank? || property.nil? || starts_at.blank? || ends_at.blank?

    start_time = starts_at.beginning_of_day
    end_time   = ends_at.end_of_day

    overlapping_bookings = property.bookings
                                   .where(room_id: room_id)
                                   .where.not(id: id)
                                   .where("starts_at < ? AND ends_at > ?", end_time, start_time)

    return unless overlapping_bookings.exists?

    errors.add(:base, I18n.t("activerecord.errors.models.booking.attributes.base.overlapping_booking"))
  end

end
