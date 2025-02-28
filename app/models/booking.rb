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

  validates :adults, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :children, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validate :ends_at_after_starts_at
  validate :no_overlapping_bookings

  scope :upcoming, -> { where("starts_at > ?", DateTime.now) }
  scope :past, -> { where("ends_at < ?", DateTime.now) }
  scope :current, -> { where("starts_at <= ? AND ends_at >= ?", DateTime.now, DateTime.now) }

  private

  def ends_at_after_starts_at
    return if ends_at.blank? || starts_at.blank?

    return unless ends_at < starts_at

    errors.add(:ends_at, I18n.t("activerecord.errors.models.booking.attributes.ends_at.after_starts_at"))
  end

  def no_overlapping_bookings
    overlapping_bookings = Booking.where(room_id: room_id)
                                  .where.not(id: id)
                                  .where("DATE(starts_at) < DATE(?) AND DATE(ends_at) > DATE(?)", ends_at, starts_at)

    return unless overlapping_bookings.exists?

    errors.add(:base, I18n.t("activerecord.errors.models.booking.attributes.base.overlapping_booking"))
  end

end
