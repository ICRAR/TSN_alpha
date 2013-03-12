class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :alliance_leader, :class_name => 'Alliance', :foreign_key => 'alliance_leader_id', inverse_of: :leader
  belongs_to :alliance
  has_and_belongs_to_many :trophies
  has_one :general_stats_item, :dependent => :destroy, :inverse_of => :profile
  attr_accessible :country, :first_name, :second_name, :as => [:default, :admin]
  attr_accessible :user_id, :alliance_leader_id, :alliance_id, :alliance_join_date, :trophy_ids, :general_stats_item_id, as: :admin

 before_create :build_general_stats_item

  def name
    if (first_name && second_name)
      return first_name + ' ' + second_name
    elsif (first_name)
      return first_name
    elsif (second_name)
      return second_name
    elsif (user)
      return user.email
    else
      return ""
    end

  end


  def join_alliance(alliance)
    alliance.members << self
    self.alliance_join_date = Time.now
    self.save
  end


  def general_stats_item_id
    self.general_stats_item.try :id
  end
  def general_stats_item_id=(id)
    self.general_stats_item = GeneralStatsItem.find_by_id(id)
  end
end
