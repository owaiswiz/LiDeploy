class AddPasswordToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :password, :string
  end
end
