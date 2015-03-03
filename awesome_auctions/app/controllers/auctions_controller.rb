class AuctionsController < ApplicationController
  def create
    product = Product.find params[:product_id]
    auction = Auction.new auction_params.merge! product_id: product.id

    if auction.save
      redirect_to product, notice: "Product was put to auction."
    else
      unless auction.errors.any?
        redirect_to product, alert: "An error occurred. Please check the form for errors."
      else
        # TODO : Make this not terrible
        errors_string = "";
        auction.errors.full_messages.each do |msg|
          errors_string += msg + " "
        end
        redirect_to product, alert: errors_string
      end
    end
  end

  def auction_params
    params.require(:auction).permit(:value, :ends_at)
  end
end
