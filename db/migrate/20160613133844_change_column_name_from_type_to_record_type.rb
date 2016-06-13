class ChangeColumnNameFromTypeToRecordType < ActiveRecord::Migration
  def change
    rename_column :records, :type, :record_type
  end
end
