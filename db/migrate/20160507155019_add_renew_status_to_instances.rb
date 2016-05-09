class AddRenewStatusToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :renew_status, :string
  end
end
