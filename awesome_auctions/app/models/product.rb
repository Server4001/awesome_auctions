class Product < ActiveRecord::Base
  # Class constants
  URL_REGEX = /\A(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?\z/

  # Model associations
  belongs_to :user

  # Model validations
  validates :name, presence: true
  validates :image, presence: true, format: {with: URL_REGEX, message: "must be a valid URL starting with: http://...", multiline: true}
end
