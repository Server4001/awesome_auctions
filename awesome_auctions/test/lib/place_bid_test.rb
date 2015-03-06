# run using: rake test:lib
require "test_helper"
require "place_bid"

class PlaceBidTest < MiniTest::Test
  def setup
    @user = User.create! email: "test@test.com", password: "password"
    @another_user = User.create! email: "anotheremail@test.com", password: "another_password"
    @product = Product.create! name: "Some Name", image: "http://www.image.com/path/to/image.png"
    @auction = Auction.create! value: 10, product_id: @product.id, ends_at: 7.days.from_now
  end

  def test_it_places_a_bid
    service = PlaceBid.new value: 11, user: @another_user, auction: @auction
    service.execute

    assert_equal 11, @auction.current_bid_value
  end

  def test_fails_to_place_bid_under_current_value
    bid_too_small = false
    service = PlaceBid.new user: @another_user, auction: @auction, value: 9.99

    begin
      service.execute
    rescue BidTooSmall
      bid_too_small = true
    end

    assert bid_too_small
  end

  def test_notifies_user_if_user_already_won_auction
    auction_ended = false
    service = PlaceBid.new user: @user, auction: @auction, value: 11
    service.execute

    another_service = PlaceBid.new user: @user, auction: @auction, value: 15
    Timecop.travel(8.days.from_now)
    begin
      another_service.execute
    rescue AuctionEnded
      auction_ended = true
    end

    assert_equal :won, another_service.status
    assert auction_ended
  end

  def test_notifies_user_if_another_already_won_auction
    auction_ended = false
    service = PlaceBid.new user: @another_user, auction: @auction, value: 11
    service.execute

    another_service = PlaceBid.new user: @user, auction: @auction, value: 15
    Timecop.travel(8.days.from_now)
    begin
      another_service.execute
    rescue AuctionEnded
      auction_ended = true
    end

    assert_equal :lost, another_service.status
    assert auction_ended
  end

  private

  attr_reader :user, :another_user, :product, :auction
end
