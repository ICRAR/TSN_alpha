class Alliance < ActiveRecord::Base
  acts_as_taggable

  attr_accessible :name,:tags,:desc,:country, :old_id, :tag_list, :invite_only, :is_boinc,  :as => [:default, :admin]
  attr_accessible :leader_id, :member_ids, as: :admin

  validates :name, uniqueness: true

  scope :temp_credit, joins(:member_items).select("alliances.*, sum(alliance_members.leave_credit-IFNULL(alliance_members.start_credit,0)) as temp_credit").group('alliances.id')
  scope :temp_rac, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.recent_avg_credit) as temp_rac, count(general_stats_items.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")
  scope :for_leaderboard, where("credit IS NOT NULL").includes(:leader)
  scope :for_leaderboard_small, where("credit IS NOT NULL")

  has_one :leader, :foreign_key => "alliance_leader_id", :class_name => 'Profile', :inverse_of => :alliance_leader
  has_many :member_items, :class_name => 'AllianceMembers', :dependent => :destroy
  has_many :members, :class_name => 'Profile', :inverse_of => :alliance
  has_many :invites, :class_name => "AllianceInvite", :inverse_of => :alliance, :dependent => :destroy

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

  def joinable?
    (!is_boinc?) && (!invite_only?)
  end

  include Tire::Model::Search
  #include Tire::Model::Callbacks
  after_save do
    begin
      update_index
    rescue Errno::ECONNREFUSED
    end
  end

  mapping do
    indexes :name, analyzer: 'snowball', tokenizer: 'nGram'
    indexes :tags, :as => 'tag_list.to_s', analyzer: 'snowball', tokenizer: 'nGram'
  end

  def self.search(query,page,per_page)
    tire.search(:page => (page || 1), :per_page => per_page, :load => {:include => 'leader'}) do
      query do
        boolean(:minimum_number_should_match => 1) do
          should {fuzzy :name, query}
          should {match :name, query}
          should {prefix :name, query}
          should {fuzzy :tags, query}
          should {match :tags, query}
          should {prefix :tags, query}
        end
      end
    end
  end



  #because of a double up between BOINC and classic theSkynet Team's and alliances we need away to safely merge two alliances
  #this function should be called on the pogs alliances the one that will remain
  def merge_pogs_team(second_alliance)
    raise 'second alliance must be a classic alliance' if second_alliance.is_boinc?
    #merge params
    self.old_id = second_alliance.old_id
    self.tag_list = second_alliance.tag_list
    #merge users
    #move alliance_members
    AllianceMembers.where{alliance_id == my{second_alliance.id}}.update_all(:alliance_id => self.id)
    #update_current members
    Profile.where{alliance_id == my{second_alliance.id}}.update_all(:alliance_id => self.id)
    #handle duplicate users
    #first we grab all the member items
    members = self.member_items.group_by{|m| m.profile_id}
    #group by profile id's
    members.each do |profile_id,memberships|
      #then we sort them by join_date
      memberships = memberships.sort_by {|m| m.join_date}
      overlaping = []
      leave_date = nil
      m_overlaping = []
      #and group them if they overlap
      #m_overlaping will be an array of an array of memberships
      #overlaping is a temp array of overlaping memberships
      memberships.each do |m|
        if overlaping == []
          #if overlaping is empty we add a membership to it
          overlaping << m
          leave_date = m.leave_date.nil? ? Time.now : m.leave_date
        else
          #check if this one matches the overlap ie join_date is less than leave_date
          if m.join_date < leave_date
            #there is a match
            #add to overlapping
            overlaping << m
            #update leave_date
            leave_date = [leave_date,(m.leave_date.nil? ? Time.now : m.leave_date)].max
          else
            #there is no overlap start new group
            m_overlaping << overlaping
            overlaping = []
            #add to overlapping
            overlaping << m
            #update leave_date
            leave_date = [leave_date,(m.leave_date.nil? ? Time.now : m.leave_date)].max
          end
        end
      end
      m_overlaping << overlaping if overlaping != []
      #m_overlaping  now contains all the memberships sorted into overlaping groups

      m_overlaping.each do |group|
        #if there is only one membership in the group there was no overlap here so do nothing
        if group.size > 1
          #otherwise there was an overlap so we need to make a new member item and delete the old ones
          join_dates = group.map {|m| m.join_date}
          leave_dates = group.map {|m| m.leave_date}
          start_credits = group.map {|m| m.start_credit}
          leave_credits = group.map {|m| m.leave_credit}

          #new item will have the min start date and credit and max leave date and credit
          new_join_date = join_dates.min
          new_leave_date = leave_dates.include?(nil) ? nil : leave_dates.max
          new_start_credit = start_credits.min
          new_leave_credit = leave_credits.max

          member = AllianceMembers.new
          member.alliance_id = self.id
          member.profile_id = profile_id
          member.join_date = new_join_date
          member.start_credit = new_start_credit
          member.leave_credit = new_leave_credit
          member.leave_date = new_leave_date
          member.save

          group.each {|m| m.delete}
        end
      end
    end
    second_alliance.delete
  end
end
