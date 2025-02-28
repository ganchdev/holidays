# frozen_string_literal: true

class BookingsController < ApplicationController

  before_action :set_property
  before_action :set_room
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  # GET /properties/:property_id/rooms/:room_id/bookings
  def index
    @bookings = @room.bookings
  end

  # GET /properties/:property_id/rooms/:room_id/bookings/:id
  def show
  end

  # GET /properties/:property_id/rooms/:room_id/bookings/new
  def new
    @booking = @room.bookings.build
  end

  # GET /properties/:property_id/rooms/:room_id/bookings/:id/edit
  def edit
  end

  # POST /properties/:property_id/rooms/:room_id/bookings
  def create
    @booking = @room.bookings.build(booking_params)

    if @booking.save
      redirect_to property_room_booking_path(@property, @room, @booking),
                  notice: t("flash.bookings.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/:property_id/rooms/:room_id/bookings/:id
  def update
    if @booking.update(booking_params)
      redirect_to property_room_booking_path(@property, @room, @booking),
                  notice: t("flash.bookings.updated_successfully"), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:property_id/rooms/:room_id/bookings/:id
  def destroy
    @booking.destroy!
    redirect_to property_room_bookings_path(@property, @room), notice: t("flash.bookings.destroyed_successfully"),
                                                               status: :see_other
  end

  private

  def set_property
    @property = Current.account.properties.find(params[:property_id])
  end

  def set_room
    @room = @property.rooms.find(params[:room_id])
  end

  def set_booking
    @booking = @room.bookings.find(params[:id])
  end

  def booking_params
    params.expect(booking: [:adults, :children, :deposit, :notes, :starts_at, :ends_at])
  end

end
