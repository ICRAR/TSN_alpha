class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :alliance_leader, :class_name => 'Alliance', :foreign_key => 'alliance_leader_id'
  belongs_to :alliance
  attr_accessible :country, :first_name, :second_name

  def alliance_link
    alliance ? link_to(alliance.name,alliance) : 'Flying Solo'
  end

end
