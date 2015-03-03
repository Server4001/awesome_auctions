class PlaceBid
  # Access number_to_currency()
  include ActionView::Helpers::NumberHelper

  def initialize options
    @value = options[:value].to_f
    @user = options[:user]
    @auction = options[:auction]
  end

  def execute
    current_bid_value = @auction.current_bid_value
    raise Exception, "Bid price must be greater than #{number_to_currency(current_bid_value)}" if @value <= current_bid_value

    bid = @auction.bids.build value: @value, user_id: @user.id

    if bid.save
      return true
    elsif bid.errors.any?
      # TODO : Make this not terrible
      errors_list = ""
      bid.errors.full_messages.each do |message|
        errors_list += message + "   ";
      end

      raise Exception, "The following #{pluralize(bid.errors.count, "error")} occurred: #{errors_list}"
    else
      return false
    end
  end
end
