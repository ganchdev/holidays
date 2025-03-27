# frozen_string_literal: true

# The CalendarGeneratorService generates a calendar structure for a property's bookings
# organized by weeks and days for a specified year.
#
# This service:
# * Fetches all bookings for a property within the specified year
# * Groups them by date
# * Constructs a weekly calendar structure with associated bookings
#
# @example
#   calendar = CalendarGeneratorService.new(property: my_property, year: 2023).call
#   calendar.each do |week|
#     puts "Week starting: #{week[:start_date]}"
#     week[:days].each do |date, bookings|
#       puts "  #{date}: #{bookings.count} bookings"
#     end
#   end
#
class CalendarGeneratorService

  # @param property [Property] the property whose bookings will be organized
  # @param year [Integer] the year for which to generate the calendar (defaults to current year)
  def initialize(property:, year: Date.today.year)
    @property = property
    @year = year
    @start_date = Date.new(@year, 1, 1)
    @end_date = Date.new(@year, 12, 31)
  end

  # Generate and return the calendar structure
  #
  # @return [Array<Hash>] an array of week hashes, each containing:
  #   - start_date [Date] the Monday that starts the week
  #   - days [Array<Array>] 7 day entries, each con
  def call
    generate_weeks(group_bookings)
  end

  private

  attr_reader :property, :year

  # Generate a weekly calendar structure with bookings
  #
  # @param bookings [Hash] a hash mapping dates to arrays of bookings
  # @return [Array<Hash>] the constructed weekly calendar
  def generate_weeks(bookings)
    weeks = []

    current_week_start = @start_date - ((@start_date.wday - 1) % 7)

    while current_week_start <= @end_date
      weeks << build_week(current_week_start, bookings)
      current_week_start += 7
    end

    weeks
  end

  # Build a single week structure with its days and associated bookings
  #
  # @param week_start_date [Date] the Monday that starts the week
  # @param bookings_by_date [Hash] a hash mapping dates to arrays of bookings
  # @return [Hash] the constructed week with its days and bookings
  def build_week(week_start_date, bookings_by_date)
    {
      start_date: week_start_date,
      days: (0..6).map do |day_offset|
        date = week_start_date + day_offset
        [date, bookings_by_date[date] || []]
      end
    }
  end

  # Group bookings by date
  # For each booking, map it to all days it spans, then group by date
  #
  # @return [Hash] a hash mapping dates to arrays of bookings
  def group_bookings
    day_bookings_map = property_bookings.flat_map do |booking|
      (booking.starts_at.to_date...booking.ends_at.to_date).map do |day|
        [day, booking]
      end
    end

    day_bookings_map.group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
  end

  # Fetch all bookings for the property within the year's date range
  #
  # @return [Array<Booking>] an array of bookings
  def property_bookings
    @property_bookings ||= property.bookings
                                   .where("starts_at < ? AND ends_at > ?", @end_date + 1, @start_date)
                                   .to_a
  end

end
