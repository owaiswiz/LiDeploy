class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :instanceid
      t.string :name
      t.string :region
      t.string :size
      t.integer :memory
      t.integer :vcpus
      t.integer :disk
      t.datetime :created_at
      t.string :region
      t.string :image

      t.timestamps null: false
    end
  end
end
