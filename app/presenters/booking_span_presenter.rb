# frozen_string_literal: true

# BookingSpanPresenter handles the calculation of booking spans for calendar display.
# It determines how bookings should be rendered across day columns, handling:
# - Check-in days (afternoon arrival - right half of cell)
# - Checkout days (morning departure - left half of cell)
# - One-night bookings (continuous span from check-in to checkout)
# - Multi-day bookings (combining consecutive full days)
class BookingSpanPresenter

  attr_reader :booking, :date_to_index, :index_to_date

  def initialize(booking, date_to_index)
    @booking = booking
    @date_to_index = date_to_index
    @index_to_date = date_to_index.invert
  end

  # Returns an array of span hashes for rendering
  # Each span has: { start_index:, offset:, width:, half_day: }
  def spans
    return [] unless start_index

    calculate_booking_parts
    combine_consecutive_spans
  end

  def start_index
    @start_index ||= date_to_index[start_date]
  end

  def end_index
    @end_index ||= date_to_index[end_date]
  end

  def checkout_index
    @checkout_index ||= date_to_index[checkout_date]
  end

  private

  def start_date
    @start_date ||= booking.starts_at.to_date
  end

  def end_date
    @end_date ||= booking.ends_at.to_date - 1.day
  end

  def checkout_date
    @checkout_date ||= booking.ends_at.to_date
  end

  def one_night_booking?
    checkout_index && start_index && checkout_index == start_index + 1
  end

  def calculate_booking_parts
    @booking_parts = []

    # Add regular booking days (full occupancy nights)
    add_occupancy_days if end_index

    # Add checkout day (morning departure) for multi-night bookings
    add_checkout_day if checkout_index && checkout_index != start_index && !one_night_booking?
  end

  def add_occupancy_days
    (start_index..end_index).each do |day_index|
      current_date = index_to_date[day_index]

      if checkin_day?(current_date)
        add_checkin_day(day_index)
      else
        add_full_day(day_index)
      end
    end
  end

  def checkin_day?(date)
    date == start_date
  end

  def add_checkin_day(day_index)
    if one_night_booking?
      # One-night: continuous span from check-in (afternoon) through checkout (morning)
      @booking_parts << { index: day_index, offset: 0.5, width: 1 }
    else
      # Multi-night: right half only (afternoon arrival)
      @booking_parts << { index: day_index, offset: 0.5, width: 0.5 }
    end
  end

  def add_full_day(day_index)
    @booking_parts << { index: day_index, offset: 0, width: 1 }
  end

  def add_checkout_day
    # Left half only (morning departure)
    @booking_parts << { index: checkout_index, offset: 0, width: 0.5 }
  end

  def combine_consecutive_spans
    combined = []
    current_span = nil

    @booking_parts.each do |part|
      if consecutive_full_day?(part, current_span)
        extend_current_span(current_span, part)
      else
        combined << current_span if current_span
        current_span = new_span(part)
      end
    end

    combined << current_span if current_span
    combined
  end

  def consecutive_full_day?(part, current_span)
    part[:width] == 1 &&
      current_span &&
      part[:index] == current_span[:end_index] + 1 &&
      part[:offset].zero?
  end

  def extend_current_span(span, part)
    span[:end_index] = part[:index]
    span[:width] = span[:end_index] - span[:start_index] + 1
    span[:half_day] = false # Extended spans are no longer half-day
  end

  def new_span(part)
    {
      start_index: part[:index],
      end_index: part[:index],
      offset: part[:offset],
      width: part[:width],
      half_day: part[:width] == 0.5 # rubocop:disable Lint/FloatComparison
    }
  end

end
