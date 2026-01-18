# frozen_string_literal: true

# rbs_inline: enabled

# The CalendarGeneratorService generates a calendar structure for a property's bookings
# organized by days for a specified year.
#
# This service:
# * Fetches all bookings for a property within the specified year
# * Groups them by date
# * Returns an array of [date, bookings] tuples for each day
#
# @example
#   calendar = CalendarGeneratorService.new(property: my_property, year: 2023).call
#   calendar.each do |date, bookings|
#     puts "#{date}: #{bookings.count} bookings"
#   end
#
class CalendarGeneratorService

  # @rbs property: Property
  # @rbs year: Integer
  # @rbs return: CalendarGeneratorService
  def initialize(property:, year: Date.today.year)
    @property = property
    @year = year
    @start_date = Date.new(@year, 1, 1)
    @end_date = Date.new(@year + 1, 12, 31)
  end

  # Generate and return the calendar structure as an array of days with bookings
  #
  # @rbs return: Array[[Date, Array[Booking]]]
  def call
    bookings = group_bookings

    (@start_date..@end_date).map do |date|
      [date, bookings[date] || []]
    end
  end

  private

  attr_reader :property #: Property
  attr_reader :year #: Integer

  # Group bookings by date
  # For each booking, map it to all days it spans, then group by date
  #
  # @rbs return: Hash[Date, Array[Booking]]
  def group_bookings
    grouped_bookings = {} #: Hash[Date, Array[Booking]]

    property_bookings.each do |booking|
      (booking.starts_at.to_date...booking.ends_at.to_date).each do |day|
        grouped_bookings[day] ||= []
        grouped_bookings[day] << booking
      end
    end

    grouped_bookings
  end

  # Fetch all bookings for the property within the year's date range
  #
  # @rbs return: Array[Booking]
  def property_bookings
    @property_bookings ||= property.bookings
                                   .active
                                   .where("starts_at < ? AND ends_at > ?", @end_date + 1, @start_date)
                                   .to_a
  end

end
