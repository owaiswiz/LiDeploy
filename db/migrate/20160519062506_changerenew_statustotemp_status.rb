class ChangerenewStatustotempStatus < ActiveRecord::Migration
  def change
    rename_column :instances,:renew_status,:temp_status
  end
end
