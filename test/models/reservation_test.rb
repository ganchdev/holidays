# frozen_string_literal: true

# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  adults       :integer
#  cancelled_at :datetime
#  children     :integer
#  notes        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  room_id      :integer          not null
#
# Indexes
#
#  index_reservations_on_room_id  (room_id)
#
require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
