class AddIpAddressApiKeyDurationExpiresToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :ip_address, :string
    add_column :instances, :api_key, :string
    add_column :instances, :duration, :integer
    add_column :instances, :expires, :datetime
  end
end
