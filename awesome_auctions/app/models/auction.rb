class Auction < ActiveRecord::Base
  # ActiveRecord associations
  belongs_to :product
  has_many :bids, dependent: :destroy

  # Model validations
  validates :value, presence: true, numericality: {greater_than: 0}
  validates :ends_at, presence: true, date: {after: Proc.new {Time.now}, before_or_equal_to: Proc.new {30.days.from_now}, message: "must be sometime in the next 30 days"}, on: :create

  # Custom methods
  def top_bid
    bids.order(value: :desc, created_at: :asc).first
  end

  def current_bid_value
    (top_bid.nil? ? value : top_bid.value)
  end

  def top_bid_is_mine? user
    if top_bid.nil? or top_bid.user_id != user.id
      return false
    else
      return true
    end
  end

  def ended?
    if ends_at < Time.now
      true
    else
      false
    end
  end

  def has_not_ended?
    !ended?
  end

  def i_bid_on_this? user
    bids.where(user_id: user.id).count > 0
  end

  def self.process_ended
    auctions = self.where("processed = ? AND ends_at <= ?", false, Time.now)
    auctions.each do |auction|
      product = auction.product

      # Transfer product to winner
      unless auction.top_bid.nil? or product.transferred
        product.user_id = auction.top_bid.user.id
        product.transferred = true
        product.save
      end

      # Set processed to true
      auction.update(processed: true)

      # TODO : Send push notifications
    end
  end
end
