class Record < ActiveRecord::Base
  belongs_to :domain
  scope :alphabetically,-> {order('record_type ASC')}
end
