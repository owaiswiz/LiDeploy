class AddApiKeyToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :api_key, :string
  end
end
