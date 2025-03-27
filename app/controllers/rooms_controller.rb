# frozen_string_literal: true

class RoomsController < ApplicationController

  before_action :find_property
  before_action :find_room, only: [:edit, :update, :destroy]

  # GET /properties/:property_id/rooms
  def index
    @rooms = @property.rooms
  end

  # GET /properties/:property_id/rooms/new
  def new
    @room = @property.rooms.build
  end

  # GET /properties/:property_id/rooms/:id/edit
  def edit
  end

  # POST /properties/:property_id/rooms
  def create
    @room = @property.rooms.build(room_params)

    if @room.save
      redirect_to property_rooms_path(@property), notice: t("flash.rooms.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/:property_id/rooms/:id
  def update
    if @room.update(room_params)
      redirect_to property_rooms_path(@property), notice: t("flash.rooms.updated_successfully"),
                                                  status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:property_id/rooms/:id
  def destroy
    @room.destroy!
    redirect_to property_rooms_path(@property), notice: t("flash.rooms.destroyed_successfully"), status: :see_other
  end

  private

  def find_property
    @property = Current.account.properties.find(params[:property_id])
  end

  def find_room
    @room = @property.rooms.find(params[:id])
  end

  def room_params
    params.expect(room: [:name, :capacity, :color, :property_id])
  end

end
