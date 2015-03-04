class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :transfer]
  before_filter :confirm_ownership, only: [:edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @auction = @product.auction
    @top_bid = (@auction.nil? ? nil : @auction.current_bid_value)
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params.merge! user_id: current_user.id)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /products/1/transfer
  def transfer
    if @product.auction.ended? and (@product.user_id === current_user.id or @product.auction.top_bid_is_mine? current_user) and !@product.transferred
      @product.update user_id: @product.auction.top_bid.user_id, transferred: true
      redirect_to @product, notice: "Successfully transfered the product."
    else
      redirect_to @product, alert: "This product cannot be transferred."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :image)
    end

  def confirm_ownership
    unless @product.belongs_to_user? current_user
      redirect_to products_url, alert: 'Only the owner of an auction can update or delete it.'
    end
  end
end
