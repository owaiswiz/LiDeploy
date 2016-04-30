class Instance < ActiveRecord::Base
  belongs_to :user
  def paypal_url(return_path,inst)
    values = {
        business: "support@lideploy.com",
        cmd: "_xclick",
        upload: 1,
        return: "#{Rails.application.secrets.app_host}/instances/show",
        invoice: inst.id,
        amount: '3.99',
        item_name: inst.name,
        item_number: inst.id,
        quantity: '1',
        notify_url: "#{Rails.application.secrets.app_host}/hook"
    }
    "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
  end
end
