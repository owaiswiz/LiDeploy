class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :type
      t.string :name
      t.string :data
      t.integer :priority
      t.integer :port
      t.integer :weight

      t.timestamps null: false
    end
  end
end
