class Auction < ActiveRecord::Base
  # ActiveRecord associations
  belongs_to :product
  has_many :bids, dependent: :destroy

  # Model validations
  validates :value, presence: true, numericality: {greater_than: 0}
  validates :ends_at, presence: true, date: {after: Proc.new {Time.now}, before_or_equal_to: Proc.new {30.days.from_now}, message: "must be sometime in the next 30 days"}

  # Custom methods
  def top_bid
    bids.order(value: :desc, created_at: :asc).first
  end

  def current_bid_value
    (top_bid.nil? ? value : top_bid.value)
  end

  def top_bid_is_mine? user
    top_bid.user_id === user.id
  end
end
