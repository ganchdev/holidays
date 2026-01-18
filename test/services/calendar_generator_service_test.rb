# frozen_string_literal: true

require "test_helper"

class CalendarGeneratorServiceTest < ActiveSupport::TestCase

  def setup
    @property = properties(:one)
    @year = 2023
    @start_date = Date.new(@year, 1, 1)
    @end_date = Date.new(@year, 12, 31)

    # Clear existing bookings
    Booking.delete_all

    # Create test bookings that span different periods
    @booking1 = Booking.create!(
      room: rooms(:one),
      adults: 2,
      starts_at: Date.new(2023, 1, 10),
      ends_at: Date.new(2023, 1, 15)
    )

    @booking2 = Booking.create!(
      room: rooms(:two),
      adults: 1,
      starts_at: Date.new(2023, 2, 5),
      ends_at: Date.new(2023, 2, 12)
    )

    @booking3 = Booking.create!(
      room: rooms(:one),
      adults: 3,
      starts_at: Date.new(2023, 12, 28),
      ends_at: Date.new(2024, 1, 5)
    )

    # Booking outside the target year
    @booking4 = Booking.create!(
      room: rooms(:two),
      adults: 2,
      starts_at: Date.new(2022, 12, 25),
      ends_at: Date.new(2023, 1, 2)
    )

    # Associate bookings with property
    @property.rooms = [@booking1.room, @booking2.room, @booking3.room, @booking4.room]
  end

  test "should correctly map bookings to days" do
    service = CalendarGeneratorService.new(property: @property, year: @year)
    days = service.call

    # Test overall structure - should be an array of [date, bookings] tuples
    assert_kind_of Array, days
    assert days.all? { |day| day.is_a?(Array) && day.length == 2 } # rubocop:disable Lint/AmbiguousBlockAssociation

    # Find specific dates to check bookings
    jan_10_data = find_date_in_days(days, Date.new(2023, 1, 10))
    jan_14_data = find_date_in_days(days, Date.new(2023, 1, 14))
    feb_8_data = find_date_in_days(days, Date.new(2023, 2, 8))
    dec_30_data = find_date_in_days(days, Date.new(2023, 12, 30))
    jan_1_data = find_date_in_days(days, Date.new(2023, 1, 1))

    # Check correct bookings are mapped to dates
    assert_includes jan_10_data, @booking1
    assert_includes jan_14_data, @booking1
    assert_includes feb_8_data, @booking2
    assert_includes dec_30_data, @booking3
    assert_includes jan_1_data, @booking4

    # Check dates outside booking periods
    jan_16_data = find_date_in_days(days, Date.new(2023, 1, 16))
    assert_empty jan_16_data
  end

  test "should handle empty properties" do
    empty_property = properties(:without_bookings)

    service = CalendarGeneratorService.new(property: empty_property, year: @year)
    days = service.call

    assert_kind_of Array, days
    assert days.length.positive?

    # All days should have empty booking arrays
    days.each do |_date, bookings| # rubocop:disable Style/HashEachMethods
      assert_empty bookings
    end
  end

  # rubocop:disable Naming/VariableNumber
  test "should handle bookings that span year boundaries" do
    service = CalendarGeneratorService.new(property: @property, year: @year)
    days = service.call

    # Check @booking4 (spans from 2022 to 2023)
    jan_1_data = find_date_in_days(days, Date.new(2023, 1, 1))
    assert_includes jan_1_data, @booking4

    # Check @booking3 (spans from 2023 to 2024)
    dec_31_data = find_date_in_days(days, Date.new(2023, 12, 31))
    assert_includes dec_31_data, @booking3

    # The service should only include days within the target year
    service_2024 = CalendarGeneratorService.new(property: @property, year: 2024)
    days_2024 = service_2024.call

    jan_3_data_2024 = find_date_in_days(days_2024, Date.new(2024, 1, 3))
    assert_includes jan_3_data_2024, @booking3
  end
  # rubocop:enable Naming/VariableNumber

  private

  def find_date_in_days(days, target_date)
    days.each do |date, bookings|
      return bookings if date == target_date
    end
    []
  end

end
