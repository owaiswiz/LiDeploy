class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.string :ip_address
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
