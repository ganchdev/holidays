# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
class BookingsController < ApplicationController

  layout "bookings", only: [:index, :show]
  layout "application", only: [:new, :create, :edit, :update]

  before_action :find_property
  before_action :find_booking, only: [:show, :edit, :update, :destroy]

  # GET /properties/:property_id/bookings
  def index
    @rooms = @property.rooms.sort_by { |r| r.name.to_i }
    @days = CalendarGeneratorService.new(property: @property).call
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

    @bookings = @property.bookings.active.for_day(@day)
  end

  # GET /properties/:property_id/bookings/new
  def new
    @booking = @property.bookings.active.build
  end

  # GET /properties/:property_id/bookings/:id/edit
  def edit
    @available_rooms = @property.rooms.available_for_booking(@booking)
  end

  # POST /properties/:property_id/bookings
  def create
    @booking = @property.bookings.active.build(booking_params)

    if params[:use_room_price]
      @booking.price = @booking&.room&.price
    end

    if params[:reload].present?
      if @booking.starts_at.present? &&
         @booking.ends_at.present? &&
         @booking.ends_at.to_date > @booking.starts_at.to_date

        available_rooms = @property.rooms.available_between(@booking.starts_at, @booking.ends_at)
      else
        available_rooms = nil
      end

      render turbo_stream:
        turbo_stream.replace(
          :booking_form,
          method: :morph,
          partial: "bookings/form",
          locals: { booking: @booking, available_rooms: available_rooms }
        )
      return
    end

    if @booking.save
      redirect_to property_booking_path(@property, @booking),
                  notice: t("flash.bookings.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/:property_id/bookings/:id
  def update
    @booking.assign_attributes(booking_params)

    if params[:use_room_price]
      @booking.price = @booking&.room&.price
    end

    if params[:reload].present?
      if @booking.starts_at.present? &&
         @booking.ends_at.present? &&
         @booking.ends_at.to_date > @booking.starts_at.to_date

        available_rooms = @property.rooms.available_for_booking(@booking)
      else
        available_rooms = nil
      end

      render turbo_stream:
        turbo_stream.replace(
          :booking_form,
          method: :morph,
          partial: "bookings/form",
          locals: { booking: @booking, available_rooms: available_rooms }
        )
      return
    end

    if @booking.save
      redirect_to property_booking_path(@property, @booking),
                  notice: t("flash.bookings.updated_successfully"),
                  status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:property_id/bookings/:id
  def destroy
    @booking.update!(cancelled_at: Time.current)
    redirect_to property_bookings_path(@property),
                notice: t("flash.bookings.destroyed_successfully"),
                status: :see_other
  end

  private

  def find_property
    @property = Current.account.properties.find(params[:property_id])
  end

  def find_booking
    @booking = @property.bookings.active.find(params[:id])
  end

  def booking_params
    params.expect(booking: [:room_id, :adults, :children, :deposit, :price, :name, :notes, :starts_at, :ends_at])
  end

end
# rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
