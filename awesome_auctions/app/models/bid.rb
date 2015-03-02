class Bid < ActiveRecord::Base
  # ActiveRecord associations
  belongs_to :user
  belongs_to :auction

  # Model validations
  validates :value, presence: true, numericality: {greater_than: 0}
end
