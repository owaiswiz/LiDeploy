class AddCreatedByToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :created_by, :string
  end
end
