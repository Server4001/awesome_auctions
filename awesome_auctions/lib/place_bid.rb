require File.expand_path "../exceptions/bid_too_small", __FILE__
require File.expand_path "../exceptions/non_numeric", __FILE__

class PlaceBid
  def initialize options
    if (Float(options[:value]) rescue false) === false
      raise NonNumeric, "Bid price must be a number"
    end

    @value = options[:value].to_f
    @user = options[:user]
    @auction = options[:auction]
  end

  def execute
    current_bid_value = @auction.current_bid_value
    raise BidTooSmall, "Bid price must be greater than #{current_bid_value}" if @value <= current_bid_value

    bid = @auction.bids.build value: @value, user_id: @user.id

    if bid.save
      true
    elsif bid.errors.any?
      # TODO : Make this not terrible
      errors_list = ""
      bid.errors.full_messages.each do |message|
        errors_list += message + "   ";
      end

      raise Exception, "The following error(s) occurred: #{errors_list}"
    else
      false
    end
  end
end
