class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :user_id
      t.string :title
      t.text :message
      t.string :status

      t.timestamps null: false
    end
  end
end
