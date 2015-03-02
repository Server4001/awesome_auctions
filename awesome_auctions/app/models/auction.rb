class Auction < ActiveRecord::Base
  # ActiveRecord associations
  belongs_to :product
  has_many :bids, dependent: :destroy

  # Model validations
  validates :value, presence: true, numericality: {greater_than: 0}

  # Custom methods
  def top_bid
    bids.order(value: :desc, created_at: :asc).first
  end

  def current_bid_value
    (top_bid.nil? ? value : top_bid.value)
  end
end
