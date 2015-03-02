class PlaceBid
  def initialize options
    @value = options[:value]
    @user = options[:user]
    @auction = options[:auction]
  end

  def execute
    bid = @auction.bids.build value: @value, user_id: @user.id

    if bid.save
      return true
    end
  end
end
