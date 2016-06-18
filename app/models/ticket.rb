class Ticket < ActiveRecord::Base
  has_many :replies
  belongs_to :user
  default_scope {order('updated_at DESC')}
end
