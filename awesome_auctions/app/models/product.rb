class Product < ActiveRecord::Base
  # Class constants
  URL_REGEX = /\A(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\z/

  # ActiveRecord associations
  belongs_to :user
  has_one :auction, dependent: :destroy

  # Model validations
  validates :name, presence: true
  validates :image, presence: true, format: {with: URL_REGEX, message: "must be a valid URL starting with: http://...", multiline: true}

  # Custom methods
  def has_auction?
    auction.present?
  end

  def belongs_to_user? user
    user_id === user.id
  end
end
