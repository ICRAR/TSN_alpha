class Alliance < ActiveRecord::Base
  attr_accessible :name, :as => [:default, :admin]
  attr_accessible :ranking, as: :admin

  has_one :leader, :class_name => 'Profile', :foreign_key => 'alliance_leader_id', :inverse_of => :alliance_leader
  has_many :members, :class_name => 'Profile'

end
