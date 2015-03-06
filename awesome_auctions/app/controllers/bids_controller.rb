require "place_bid"

class BidsController < ApplicationController
  def create
    begin
      # TODO : Update these
      service = PlaceBid.new bid_params
      if service.execute
        redirect_to product_path(params[:product_id]), notice: "Bid successfully placed."
      else
        redirect_to product_path(params[:product_id]), alert: "An error occurred and your bid could not be placed."
      end
    rescue Exception => e
      redirect_to product_path(params[:product_id]), alert: e.message
    end
  end

  private

  def bid_params
    auction = Auction.find params[:auction_id]
    params.require(:bid)
      .permit(:value)
      .merge!({
        user: current_user,
        auction: auction
    })
  end
end
