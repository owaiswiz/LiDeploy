class AddDistroToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :distro, :string
  end
end
