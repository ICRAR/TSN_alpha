class Alliance < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_name, :against => :name,
                  :using => {:tsearch  => {:prefix => true,:dictionary => "english"},
                             :dmetaphone => {},
                             :trigram => {}}


  attr_accessible :name, :as => [:default, :admin]
  attr_accessible :ranking, :credit, :RAC, as: :admin

  scope :temp_credit, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.total_credit) as temp_credit, sum(general_stats_items.recent_avg_credit) as temp_rac, count(profiles.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")
  scope :for_leaderboard, where("credit IS NOT NULL").includes(:leader)

  has_one :leader, :class_name => 'Profile', :foreign_key => 'alliance_leader_id', :inverse_of => :alliance_leader
  has_many :members, :class_name => 'Profile'

  def self.for_show(id)
    where(:id => id).includes(:leader).first
  end



end
