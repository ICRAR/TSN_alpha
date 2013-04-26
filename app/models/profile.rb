class Profile < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_name, :against => [:first_name, :second_name],
                  :using => {:tsearch  => {:prefix => true,:dictionary => "english"},
                             :dmetaphone => {},
                             :trigram => {}}

  belongs_to :user
  belongs_to :alliance_leader, :class_name => 'Alliance', :foreign_key => 'alliance_leader_id', inverse_of: :leader
  belongs_to :alliance
  has_many :profiles_trophies, :dependent => :delete_all, :autosave => true
  has_many :trophies, :through => :profiles_trophies
  has_one :general_stats_item, :dependent => :destroy, :inverse_of => :profile
  attr_accessible :country, :first_name, :second_name, :as => [:default, :admin]
  attr_accessible :user_id, :alliance_leader_id, :alliance_id, :alliance_join_date, :trophy_ids, :general_stats_item_id, :new_profile_step, as: :admin

  scope :for_leader_boards, joins(:general_stats_item).select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac").where('general_stats_items.rank IS NOT NULL').includes(:alliance)
  scope :for_trophies, joins(:general_stats_item).select("profiles.*, general_stats_items.last_trophy_credit_value as last_trophy_credit_value, general_stats_items.total_credit as credits, general_stats_items.id as stats_id").where('general_stats_items.total_credit IS NOT NULL')

  def  self.for_show(id)
    includes(:general_stats_item => [:boinc_stats_item, :nereus_stats_item]).includes(:trophies, :user,:alliance).find(id)
  end

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

  def self.for_alliance(alliance_id)
    joins(:general_stats_item).select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits").where("general_stats_items.rank IS NOT NULL AND profiles.alliance_id = #{alliance_id}").order("rank ASC")
  end

  rails_admin do
    configure :block_grid_associations do
      visible(false)
    end
  end

end
