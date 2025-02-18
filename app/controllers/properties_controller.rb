# frozen_string_literal: true

class PropertiesController < ApplicationController

  before_action :set_property, only: [:show, :edit, :update, :destroy]

  # GET /properties
  def index
    @properties = Property.all
  end

  # GET /properties/1
  def show
  end

  # GET /properties/new
  def new
    @property = Current.account.properties.build
  end

  # GET /properties/1/edit
  def edit
  end

  # POST /properties
  def create
    @property = Current.account.properties.build(property_params)

    if @property.save
      redirect_to account_property_path(Current.account, @property), notice: "Property was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/1
  def update
    if @property.update(property_params)
      redirect_to account_property_path(Current.account, @property), notice: "Property was successfully updated.",
                                                                     status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/1
  def destroy
    @property.destroy!
    redirect_to account_properties_path(Current.account), notice: "Property was successfully destroyed.",
                                                          status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_property
    @property = Property.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def property_params
    params.expect(property: [:name, :account_id])
  end

end
