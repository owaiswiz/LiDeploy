class AddPriceToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :price, :decimal
  end
end
