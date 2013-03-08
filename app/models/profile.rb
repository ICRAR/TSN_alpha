class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :alliance_leader, :class_name => 'Alliance', :foreign_key => 'alliance_leader_id'
  belongs_to :alliance
  attr_accessible :country, :first_name, :second_name

  def name
    if (first_name && second_name)
      return first_name + ' ' + second_name
    elsif (first_name)
      return first_name
    elsif (second_name)
      return second_name
    else
      return user.email
    end
  end


  def join_alliance(alliance)
    alliance.members << self
    alliance_join_date = Time.now
  end

end
