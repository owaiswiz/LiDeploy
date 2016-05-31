class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.text :reply
      t.string :from
      t.references :ticket, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
