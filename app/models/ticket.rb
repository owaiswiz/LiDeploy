class Ticket < ActiveRecord::Base
  has_many :replies
end
