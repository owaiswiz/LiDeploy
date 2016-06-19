class Domain < ActiveRecord::Base
  belongs_to :user
  has_many :records, dependent: :destroy
end
