class Investigations::ProductsController < ApplicationController
  include CountriesHelper
  include ProductsHelper

  before_action :set_investigation, only: %i[new create suggested link destroy]
  before_action :set_product, only: %i[destroy link]
  before_action :create_product, only: %i[new create suggested]
  before_action :set_countries, only: %i[new]

  # GET /investigations/1/products/new
  def new;
    excluded_product_ids = @investigation.products.map(&:id)
    @products = advanced_product_search(@product, excluded_product_ids)
  end

  # PUT /investigations/1/products/2/link
  def link
    @investigation.products << @product
    redirect_to @investigation, notice: "Product was successfully linked."
  end

  # GET /investigations/1/products/suggested
  def suggested
    excluded_product_ids = params[:excluded_products].split(",").map(&:to_i)
    @products = advanced_product_search(@product, excluded_product_ids)
    render partial: "products/suggested"
  end

  # POST /investigations/1/products
  def create
    respond_to do |format|
      if @investigation.products << @product
        format.html { redirect_to @investigation, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /investigations/1/products
  def destroy
    @investigation.products.delete(@product)
    respond_to do |format|
      format.html do
        redirect_to investigation_products_path(@investigation),
                    notice: "Product was successfully removed."
      end
      format.json { head :no_content }
    end
  end

private

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end
end
