class AddParamsStatusTransactionIdPurchasedAtToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :notification_params, :text
    add_column :instances, :status, :string
    add_column :instances, :transaction_id, :string
    add_column :instances, :purchased_at, :datetime
  end
end
