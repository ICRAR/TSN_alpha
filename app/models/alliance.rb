class Alliance < ActiveRecord::Base
  acts_as_taggable

  attr_accessible :name,:tags,:desc,:country, :old_id, :tag_list, :invite_only, :is_boinc,  :as => [:default, :admin]
  attr_accessible :leader_id, :member_ids, as: :admin

  validates :name, uniqueness: true, presence: true
  validates :leader, presence: true
  validate :desc_not_nil
  def desc_not_nil
    errors[:desc] << "desc can not be nil" if desc.nil?
  end
  validate :boinc_name_uniqueness
  def boinc_name_uniqueness
    if is_boinc? && (pogs_team_id.nil? || pogs_team_id == 0)
      errors[:name] << "Alliance name is already taken in POGS" unless PogsTeam.find_by_name(name).nil?
    end
  end
  validate :boinc_leader
  def boinc_leader
    if is_boinc?
      errors[:leader] << "Leader must be a member of POGS to create a POGS team" unless leader.is_pogs? || leader.nil?
    end
  end

  scope :temp_credit, joins(:member_items).select("alliances.*, sum(alliance_members.leave_credit-IFNULL(alliance_members.start_credit,0)) as temp_credit").group('alliances.id')
  scope :temp_rac, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.recent_avg_credit) as temp_rac, count(general_stats_items.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")
  scope :for_leaderboard, where("credit IS NOT NULL").includes(:leader)
  scope :for_leaderboard_small, where("credit IS NOT NULL")

  has_one :leader, :foreign_key => "alliance_leader_id", :class_name => 'Profile', :inverse_of => :alliance_leader
  has_many :member_items, :class_name => 'AllianceMembers', :dependent => :destroy
  has_many :members, :class_name => 'Profile', :inverse_of => :alliance
  has_many :invites, :class_name => "AllianceInvite", :inverse_of => :alliance, :dependent => :destroy


  ######################################################
  ####CODE for marking alliances as duplicates##########
  #### all section are marked with ALLIANCE_DUP_CODE ###
  belongs_to :duplicate_alliance, :foreign_key => :duplicate_id, :class_name => 'Alliance'

  def mark_duplicate(other_id)
    other = Alliance.find other_id
    self.duplicate_id = other_id
    self.save
    raise ArgumentError, "other Alliance is already matched"  unless other.duplicate_id.nil?
    other.duplicate_id = self.id
    other.save
  end

  def is_duplicate?
    !self.duplicate_id.nil?
  end
  ######################END#############################
  ######################################################
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
    (!invite_only?)
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

  def boinc_url
    "#{APP_CONFIG['boinc_url']}team_display.php?teamid=#{self.pogs_team_id}"
  end

  #creates this alliances as a team on POGS
  def create_pogs_team
    raise "Alliance must be valid" unless self.valid?
    raise "Alliance must be saved before creating POGS team" if self.new_record?
    raise "Alliance isn't marked as a POGS team" unless self.is_boinc?
    raise "POGS team has already been created" if self.pogs_team_id > 0
    PogsTeam.delay.create_new(self.id, self.invite_only)
    self.invite_only = true
    self.save
  end
  def test
    self.old_id = 10
    self.save
    self.reload
  end
  #because of a double up between BOINC and classic theSkynet Team's and alliances we need away to safely merge two alliances
  #this function should be called on the pogs alliances, the one that will remain
  def merge_pogs_team(second_alliance)
    raise 'second alliance must be a classic alliance' if second_alliance.is_boinc?
    raise 'first alliance must be a POGS alliance' unless self.is_boinc?

    #update_current members on POGS or remove if that's not possible
    profiles = Profile.where{alliance_id == my{second_alliance.id}}
    #add new members to POGS team on the BOINC server
    profiles.each do |profile|
      #if they don't have a boinc account
      if profile.general_stats_item.boinc_stats_item.nil?
        #remove them from the alliance
        item = profile.alliance_items.where{(leave_date == nil) & (alliance_id == my{profile.alliance.id})}.first        #send email
        item.leave_alliance_without_notification(profile)
        profile.alliance = nil
        profile.save
        UserMailer.alliance_merger_issue(profile, self).deliver
      else #if they do have a boinc account
        #add them to the POGS Team
        BoincRemoteUser.join_team profile.general_stats_item.boinc_stats_item.boinc_id, self.pogs_team_id
      end
    end


    #update_current members
    #move all profiles to the new alliance
    profiles = Profile.where{alliance_id == my{second_alliance.id}}.update_all(:alliance_id => self.id)
    #move alliance_members
    AllianceMembers.where{alliance_id == my{second_alliance.id}}.update_all(:alliance_id => self.id)

    #handle duplicate users
    #first we grab all the member items
    self.save
    self.reload
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
          #check if this one matches the overlap ie join_date is less than leave_date with a slight fuzziness of 2 hours
          if m.join_date < (leave_date + 2.hours)
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

    #fix name
    self.name = second_alliance.name

    #fix created at
    self.created_at = [self.created_at, second_alliance.created_at].min

    #merge params
    self.old_id = second_alliance.old_id
    self.tag_list = second_alliance.tag_list

    #migrate leader if needed
    self.leader ||= second_alliance.leader

    #we have to delete the second_alliance before self can be saved due to conflicts with database names
    second_alliance.delete

    self.save



  end
end
