class Profile < ActiveRecord::Base

  belongs_to :user
  belongs_to :alliance_leader, :class_name => 'Alliance', inverse_of: :leader
  belongs_to :alliance, inverse_of: :members
  has_many :alliance_items, :class_name => 'AllianceMembers'

  has_many :profiles_trophies, :dependent => :delete_all, :autosave => true
  has_many :trophies, :through => :profiles_trophies
  has_many :trophy_sets, :through => :trophies
  has_one :general_stats_item, :dependent => :destroy, :inverse_of => :profile
  has_one :invited_by, :class_name => "AllianceInvite", :inverse_of => :redeemed_by, :foreign_key => "redeemed_by_id"
  has_many :invites, :class_name => "AllianceInvite", :inverse_of => :invited_by, :foreign_key => "invited_by_id"
  attr_accessible :country, :use_full_name, :nickname, :first_name, :second_name, :as => [:default, :admin]
  attr_accessible :trophy_ids, :new_profile_step, as: :admin

  #validates :nickname, :uniqueness => true

  scope :for_leader_boards, joins(:general_stats_item).select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac").where('general_stats_items.rank IS NOT NULL').where(:general_stats_items => {:power_user => false}).includes(:alliance, :user)
  scope :for_leader_boards_small, joins(:general_stats_item).select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac").where('general_stats_items.rank IS NOT NULL').where(:general_stats_items => {:power_user => false})
  scope :for_trophies, joins(:general_stats_item).select("profiles.*, general_stats_items.last_trophy_credit_value as last_trophy_credit_value, general_stats_items.total_credit as credits, general_stats_items.id as stats_id").where('general_stats_items.total_credit IS NOT NULL')


  sifter :does_not_have_trophy do |trophy_id|
    id.not_in(ProfilesTrophy.select(:profile_id).where{profiles_trophies.trophy_id == my{trophy_id}})
  end

  #science portal memberships
  has_and_belongs_to_many :members_science_portals,
                          class_name: "SciencePortal",
                          foreign_key: "member_id",
                          association_foreign_key: "science_portal_id",
                          join_table: "members_science_portals"
  has_and_belongs_to_many :leaders_science_portals,
                          class_name: "SciencePortal",
                          foreign_key: "leader_id",
                          association_foreign_key: "science_portal_id",
                          join_table: "leaders_science_portals"

  def  self.for_show(id)
    includes(:general_stats_item => [:boinc_stats_item, :nereus_stats_item]).includes(:trophies, :user,:alliance).find(id)
  end
  def  self.for_compare(id1,id2)
    includes(:general_stats_item => [:boinc_stats_item, :nereus_stats_item]).includes(:trophies, :user,:alliance).where(:id => [id1,id2])
  end

  def self.by_nereus_id(nereus_id)
    n = NereusStatsItem.where(:nereus_id => nereus_id).first
    if n != nil && n.general_stats_item != nil
      n.general_stats_item.profile
    else
      nil
    end
  end

  before_create :build_general_stats_item
  before_destroy :leave_alliance
  def trophy_ids
    self.trophies.select("trophies.id").map(&:id)
  end
  def country_name
    ::CountrySelect::COUNTRIES[country.downcase]
  end
  def full_name
    temp_name = ''
    if (first_name)
      temp_name = first_name + temp_name
    end
    if ((first_name || second_name) && nickname)
      temp_name = temp_name + " '#{nickname}' "
    elsif (nickname)
      temp_name = nickname
    end
    if (second_name)
      temp_name = temp_name + second_name
    end
    unless (first_name || second_name || nickname)
      temp_name = user.username if user.username
    end
    temp_name.titleize
  end
  def name
    temp_name = ''
    if use_full_name
      temp_name = full_name
    else
      if (nickname)
        temp_name = nickname
      else
        temp_name = user.username if user.username
      end
    end
    return temp_name
  end


  def join_alliance(alliance)
    if self.alliance != nil
      false
    else
      self.alliance = alliance
      item = AllianceMembers.new
      item.join_date = Time.now
      item.start_credit = self.general_stats_item.total_credit
      item.start_credit ||= 0
      item.leave_credit = self.general_stats_item.total_credit
      item.start_credit ||= 0
      item.leave_date = nil

      self.alliance_items << item
      alliance.member_items << item

      item.save
      self.save
    end
  end
  def leave_alliance
    if self.alliance == nil
      false
    else
      item = self.alliance_items.where(:leave_date => nil).first
      item.leave_date = Time.now
      item.leave_credit = self.general_stats_item.total_credit
      item.save
      self.alliance = nil
      self.save
    end
  end


  def general_stats_item_id
    self.general_stats_item.try :id
  end
  def general_stats_item_id=(id)
    self.general_stats_item = GeneralStatsItem.find_by_id(id)
  end

  def self.for_alliance(alliance_id)
    joins(:general_stats_item).select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits").where("profiles.alliance_id = #{alliance_id}").order("rank ASC")
  end

  rails_admin do
    configure :block_grid_associations do
      visible(false)
    end
  end

  def avatar_url(size=48)
    default_url = "retro"
    gravatar_id = Digest::MD5.hexdigest(self.user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
  end

  def avatar_edit_url
    "http://en.gravatar.com/emails/"
  end


  def trophies_by_set
    sets = trophy_sets.order("trophy_sets.main DESC").uniq
    all_trophies = trophies.order("profiles_trophies.created_at DESC, trophies.credits DESC").group_by{|t| t.trophy_set_id}
    sets.each do |set|
      set.profile_trophies = all_trophies[set.id]
    end
    sets
  end

  #search methods
  include Tire::Model::Search
  #include Tire::Model::Callbacks
  after_save do
    begin
      update_index
    rescue Errno::ECONNREFUSED
    end
  end


  mapping do
    indexes :name, :as => 'name', analyzer: 'snowball', tokenizer: 'nGram'
  end


  def self.search(query,page = 1,per_page = 10)
    tire.search(
        :page => (page || 1),
        :per_page => per_page,
        :load => {
            :joins => :general_stats_item,
            :select => "profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac",
            :include => [:alliance, :user]
        }
    ) do
      query do
        boolean(:minimum_number_should_match => 1) do
          should {fuzzy :name, query}
          should {match :name, query}
          should {prefix :name, query}
        end
      end
    end
  end
end
