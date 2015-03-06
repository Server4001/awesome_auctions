class AddProcessedToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :processed, :boolean, default: false
  end
end
