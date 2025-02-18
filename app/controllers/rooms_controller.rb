# frozen_string_literal: true

class RoomsController < ApplicationController

  before_action :set_property
  before_action :set_room, only: [:show, :edit, :update, :destroy]

  # GET /properties/:property_id/rooms
  def index
    @rooms = @property.rooms.all
  end

  # GET /properties/:property_id/rooms/1
  def show
  end

  # GET /properties/:property_id/rooms/new
  def new
    @room = @property.rooms.build
  end

  # GET /properties/:property_id/rooms/1/edit
  def edit
  end

  # POST /properties/:property_id/rooms
  def create
    @room = @property.rooms.build(room_params)

    if @room.save
      redirect_to property_room_path(@property, @room), notice: "Room was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/:property_id/rooms/1
  def update
    if @room.update(room_params)
      redirect_to property_room_path(@property, @room), notice: "Room was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:property_id/rooms/1
  def destroy
    @room.destroy!
    redirect_to property_rooms_path(@property), notice: "Room was successfully destroyed.", status: :see_other
  end

  private

  def set_property
    @property = Current.account.properties.find(params.expect(:property_id))
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_room
    @room = Room.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def room_params
    params.expect(room: [:name, :capacity, :color, :property_id])
  end

end
