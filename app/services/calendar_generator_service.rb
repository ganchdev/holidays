# frozen_string_literal: true

# rbs_inline: enabled

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

  # @rbs property: Property
  # @rbs year: Integer
  # @rbs return: CalendarGeneratorService
  def initialize(property:, year: Date.today.year)
    @property = property
    @year = year
    @start_date = Date.new(@year, 1, 1)
    @end_date = Date.new(@year + 1, 12, 31)
  end

  # Generate and return the calendar structure
  #
  # @rbs return: Array[{ start_date: Date, days: Array[[Date, Array[Booking]]] }]
  def call
    generate_weeks(group_bookings)
  end

  def days
    bookings = group_bookings

    (@start_date..@end_date).map do |date|
      [date, bookings[date] || []]
    end
  end

  private

  attr_reader :property #: Property
  attr_reader :year #: Integer

  # Generate a weekly calendar structure with bookings,
  # it takes `bookings` as a hash mapping dates to arrays
  # of bookings
  #
  # @rbs bookings: Hash[Date, Array[Booking]]
  # @rbs return: Array[{ start_date: Date, days: Array[[Date, Array[Booking]]] }]
  def generate_weeks(bookings)
    weeks = [] #: Array[{ start_date: Date, days: Array[[Date, Array[Booking]]] }]

    current_week_start = @start_date - ((@start_date.wday - 1) % 7)

    while current_week_start <= @end_date
      weeks << build_week(current_week_start, bookings)
      current_week_start += 7
    end

    weeks
  end

  # Build a single week structure with its days and associated bookings
  # `week_start_date` is the Monday that starts the week and
  # `bookings_by_date` is a hash mapping dates to arrays of bookings
  #
  # @rbs week_start_date: Date
  # @rbs bookings_by_date: Hash[Date, Array[Booking]]
  # @rbs return: { start_date: Date, days: Array[[Date, Array[Booking]]] }
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
