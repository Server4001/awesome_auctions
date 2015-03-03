class StaticPagesController < ApplicationController
  # Skip auth check for landing page
  skip_before_filter :authenticate_user!, :only => [:home]

  # The landing page
  def home
  end
end
