class AddActionToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :action, :text
  end
end
