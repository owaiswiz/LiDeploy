class AddLastReplyFromToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :last_reply_from, :string
  end
end
