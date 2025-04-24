# frozen_string_literal: true

class PropertiesController < ApplicationController

  before_action :find_property, only: [:show, :edit, :update, :destroy]
  before_action :redirect_if_property_created, only: :new

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

  def find_property
    @property = Current.account.properties.find(params[:id])
  end

  def property_params
    params.expect(property: [:name, :account_id])
  end

  # Don't allow creating more than one property for now
  def redirect_if_property_created
    return unless Current.account.properties.count >= 1

    redirect_to root_path
  end

end
