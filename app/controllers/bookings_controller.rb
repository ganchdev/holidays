# frozen_string_literal: true

class BookingsController < ApplicationController

  layout "bookings", only: [:index, :show]
  layout "application", only: [:new, :create]

  before_action :set_property
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  # GET /properties/:property_id/bookings
  def index
    @weeks = weeks_with_bookings_for_year(Date.today.year)
  end

  # GET /properties/:property_id/bookings/:id
  def show
  end

  # GET /properities/:property_id/bookings/day
  def day
    @day = begin
      params[:day]&.to_date || Date.today
    rescue Date::Error
      Date.today
    end

    @bookings = @property.bookings.for_day(@day)
  end

  # GET /properties/:property_id/bookings/new
  def new
    @booking = @property.bookings.build
  end

  # GET /properties/:property_id/bookings/:id/edit
  def edit
  end

  # POST /properties/:property_id/bookings
  def create
    @booking = @property.bookings.build(booking_params)

    if @booking.save
      redirect_to property_booking_path(@property, @booking),
                  notice: t("flash.bookings.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/:property_id/bookings/:id
  def update
    if @booking.update(booking_params)
      redirect_to property_booking_path(@property, @booking),
                  notice: t("flash.bookings.updated_successfully"),
                  status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:property_id/bookings/:id
  def destroy
    @booking.destroy!
    redirect_to property_bookings_path(@property),
                notice: t("flash.bookings.destroyed_successfully"),
                status: :see_other
  end

  private

  def set_property
    @property = Current.account.properties.find(params[:property_id])
  end

  def set_booking
    @booking = @property.bookings.find(params[:id])
  end

  def booking_params
    params.expect(booking: [:room_id, :adults, :children, :deposit, :notes, :starts_at, :ends_at])
  end

  def weeks_with_bookings_for_year(year) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)
    weeks = []

    bookings = @property.bookings.where("starts_at < ? AND ends_at > ?", end_date + 1, start_date).to_a

    grouped = bookings.flat_map do |b|
      (b.starts_at.to_date...(b.ends_at.to_date)).map { |day| [day, b] }
    end.group_by(&:first).transform_values { |arr| arr.map(&:last) } # rubocop:disable Style/MultilineBlockChain

    # Start on the Monday of the first week
    current_week_start = start_date - ((start_date.wday - 1) % 7)

    while current_week_start <= end_date
      weeks << {
        start_date: current_week_start,
        days: (0..6).map do |i|
          day = current_week_start + i
          [day, grouped[day] || []]
        end
      }
      current_week_start += 7
    end

    weeks
  end

end
