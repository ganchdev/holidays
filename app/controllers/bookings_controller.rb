# frozen_string_literal: true

class BookingsController < ApplicationController

  layout "bookings", only: [:index, :show]
  layout "application", only: [:new, :create]

  before_action :set_property
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  # GET /properties/:property_id/bookings
  def index
    @bookings = @property.bookings
  end

  # GET /properties/:property_id/bookings/:id
  def show
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
        notice: t("flash.bookings.updated_successfully"), status: :see_other
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

end
