class RemoveMemoryFromInstances < ActiveRecord::Migration
  def change
    remove_column :instances, :memory, :integer
  end
end
