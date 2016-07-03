class ChangePriceToString < ActiveRecord::Migration
  def change
  	change_column(:instances, :price, :string)
  end
end
