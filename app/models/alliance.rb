class Alliance < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_name, :against => :name,
                  :using => {:tsearch  => {:prefix => true,:dictionary => "english"},
                             :dmetaphone => {},
                             :trigram => {}}


  attr_accessible :name,:tags,:desc,:country, :old_id,  :as => [:default, :admin]
  attr_accessible :leader_id, :member_ids, as: :admin

  scope :temp_credit, joins(:member_items).select("alliances.*, sum(alliance_members.leave_credit-alliance_members.start_credit) as temp_credit").group('alliances.id')
  scope :temp_rac, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.recent_avg_credit) as temp_rac, count(general_stats_items.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")
  scope :for_leaderboard, where("credit IS NOT NULL").includes(:leader)

  has_one :leader, :foreign_key => "alliance_leader_id", :class_name => 'Profile', :inverse_of => :alliance_leader
  has_many :member_items, :class_name => 'AllianceMembers', :dependent => :destroy
  has_many :members, :class_name => 'Profile', :inverse_of => :alliance

  def self.for_show(id)
    where(:id => id).includes(:leader).first
  end

  def leader_id
    self.leader.try :id
  end
  def leader_id=(id)
    self.leader = Profile.find_by_id(id)
  end

  rails_admin do
    configure :block_grid_associations do
      visible(false)
    end
  end
  def for_json
    result = Hash.new
    result[:id] = id
    result[:name] = name
    result[:rank] = ranking
    result[:leader] = leader.try :for_json_basic
    return  result
  end
end
