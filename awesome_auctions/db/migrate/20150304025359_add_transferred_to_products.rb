class AddTransferredToProducts < ActiveRecord::Migration
  def change
    add_column :products, :transferred, :boolean, default: false
  end
end
