# run using: rake test:lib
require "test_helper"
require "place_bid"

class PlaceBidTest < MiniTest::Test
  def setup
    @user = User.create! email: "test@test.com", password: "password"
    @another_user = User.create! email: "anotheremail@test.com", password: "another_password"
    @product = Product.create! name: "Some Name", image: "http://www.image.com/path/to/image.png"
    @auction = Auction.create! value: 10, product_id: @product.id
  end

  def test_it_places_a_bid
    service = PlaceBid.new value: 11, user: @another_user, auction: @auction
    service.execute

    assert_equal 11, @auction.current_bid_value
  end

  def test_fails_to_place_bid_under_current_value
    service = PlaceBid.new user: @another_user, auction: @auction, value: 9.99

    refute service.execute, "Bid should not be placed as value is too low"
  end

  private

  attr_reader :user, :another_user, :product, :auction
end
