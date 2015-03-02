# run using: rake test:lib
require "test_helper"
require "place_bid"

class PlaceBidTest < MiniTest::Test
  def test_it_places_a_bid
    user = User.create! email: "test@test.com", password: "password"
    another_user = User.create! email: "anotheremail@test.com", password: "another_password"
    product = Product.create! name: "Some Name", image: "http://www.image.com/path/to/image.png"
    auction = Auction.create! value: 10, product_id: product.id

    service = PlaceBid.new value: 11, user: another_user, auction: auction

    service.execute

    assert_equal 11, auction.current_bid_value
  end
end
