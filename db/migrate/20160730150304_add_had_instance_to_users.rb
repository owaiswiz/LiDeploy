class AddHadInstanceToUsers < ActiveRecord::Migration
  def change
  	 add_column :users, :had_instance, :boolean, :default => false
  end
end
