class AddDomainIdtoRecords < ActiveRecord::Migration
  def change
    change_table :records do |t|
      t.references :domain, index: true, foreign_key: true
    end
  end
end
