class Alliance < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_name, :against => :name,
                  :using => {:tsearch  => {:prefix => true,:dictionary => "english"},
                             :dmetaphone => {},
                             :trigram => {}}


  attr_accessible :name, :as => [:default, :admin]
  attr_accessible :leader_id, :member_ids, as: :admin

  scope :temp_credit, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.total_credit) as temp_credit, sum(general_stats_items.recent_avg_credit) as temp_rac, count(profiles.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")
  scope :for_leaderboard, where("credit IS NOT NULL").includes(:leader)

  has_one :leader, :class_name => 'Profile'
  has_many :members, :class_name => 'Profile'

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
