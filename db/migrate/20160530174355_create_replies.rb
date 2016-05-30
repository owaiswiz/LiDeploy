class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.integer :ticket_id
      t.text :message
      t.string :from

      t.timestamps null: false
    end
  end
end
