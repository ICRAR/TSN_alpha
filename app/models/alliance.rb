class Alliance < ActiveRecord::Base
  attr_accessible :name

  has_one :leader, :class_name => 'Profile', :foreign_key => 'alliance_leader_id'
  has_many :members, :class_name => 'Profile'

end
