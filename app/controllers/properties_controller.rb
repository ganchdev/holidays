# frozen_string_literal: true

class PropertiesController < ApplicationController

  before_action :set_property, only: [:show, :edit, :update, :destroy]

  # GET /properties
  def index
    @properties = Current.account.properties
  end

  # GET /properties/:id
  def show
  end

  # GET /properties/new
  def new
    @property = Current.account.properties.build
  end

  # GET /properties/:id/edit
  def edit
  end

  # POST /properties
  def create
    @property = Current.account.properties.build(property_params)

    if @property.save
      redirect_to property_path(@property), notice: t("flash.properties.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/:id
  def update
    if @property.update(property_params)
      redirect_to property_path(@property), notice: t("flash.properties.updated_successfully"), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:id
  def destroy
    @property.destroy!
    redirect_to properties_path, notice: t("flash.properties.destroyed_successfully"), status: :see_other
  end

  private

  def set_property
    @property = Current.account.properties.find(params[:id])
  end

  def property_params
    params.expect(property: [:name, :account_id])
  end

end
