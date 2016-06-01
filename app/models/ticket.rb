class Ticket < ActiveRecord::Base
  has_many :replies
  default_scope {order('updated_at DESC')}
end
