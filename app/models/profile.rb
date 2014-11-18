class Profile < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  belongs_to :user
  belongs_to :alliance_leader, :class_name => 'Alliance', inverse_of: :leader
  belongs_to :alliance, inverse_of: :members
  has_many :alliance_items, :class_name => 'AllianceMembers'
  has_many :activities

  has_many :profiles_trophies, :dependent => :destroy
  has_many :trophies, :through => :profiles_trophies
  has_many :trophy_sets, :through => :trophies
  has_many :comments
  has_many :comments_wall, as: :commentable, class_name: 'Comment'
  attr_readonly :comments_count
  has_many :profile_notifications
  before_destroy :remove_trophies

  scope :select_name, select{[:id, :user_id, :first_name, :second_name, :nickname, :use_full_name]}.preload(:user)

  def remove_trophies
    self.profiles_trophies.delete_all
  end
  has_one :general_stats_item, :dependent => :destroy, :inverse_of => :profile
  has_one :invited_by, :class_name => "AllianceInvite", :inverse_of => :redeemed_by, :foreign_key => "redeemed_by_id"
  has_many :invites, :class_name => "AllianceInvite", :inverse_of => :invited_by, :foreign_key => "invited_by_id"
  attr_accessible :description, :country, :use_full_name, :nickname, :first_name, :second_name, :old_site_user,  :as => [:default, :admin]
  attr_accessible :trophy_ids, :new_profile_step, as: :admin

  #THESKYMAP functions
  has_one :the_sky_map_player, :class_name => 'TheSkyMap::Player'

  #validates :nickname, :uniqueness => true

  scope :for_leader_boards, joins(:general_stats_item).
      select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac").
      where('general_stats_items.rank IS NOT NULL').where(:general_stats_items => {:power_user => false}).
      includes(:alliance, :user)
  scope :for_leader_boards_small, joins(:general_stats_item).
      select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac").
      where('general_stats_items.rank IS NOT NULL').
      where(:general_stats_items => {:power_user => false})
  scope :for_trophies, joins(:general_stats_item).
      select("profiles.*, general_stats_items.last_trophy_credit_value as last_trophy_credit_value, general_stats_items.total_credit as credits, general_stats_items.id as stats_id").
      where('general_stats_items.total_credit IS NOT NULL')

  scope :for_external_stats, joins(:general_stats_item).includes(:general_stats_item => [:boinc_stats_item, :nereus_stats_item])
      select("profiles.*, general_stats_items.rank as rank, general_stats_items.total_credit as credits, general_stats_items.recent_avg_credit as rac").
      where('general_stats_items.rank IS NOT NULL').
      where(:general_stats_items => {:power_user => false}).
      includes(:alliance, :user)


  sifter :does_not_have_trophy do |trophy_id|
    id.not_in(ProfilesTrophy.select(:profile_id).where{(profiles_trophies.trophy_id == my{trophy_id}) & (profiles_trophies.profile_id != nil)})
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

  def science_portals_all
    members_science_portals + leaders_science_portals
  end
  #challengers
  has_many :challengers, as: :entity
  #sets up simple messaging
  acts_as_messageable


  #Returning the email address of the model if an email should be sent for this object (Message or Notification).
  #If no mail has to be sent, return nil.
  def mailboxer_email(object)
    #Check if an email should be sent for that object
    #if true
    #return "define_email@on_your.model"
    #if false
    return nil
  end

  #adds social methods using the socialization gem
  # https://github.com/cmer/socialization
  # profiles can follow each other
  acts_as_followable
  acts_as_follower

  def followers_for_show
    self.followers_relation(Profile).includes(:user)
  end
  def followees_for_show
    self.followees_relation(Profile).includes(:user)
    end
  def followers_for_friends
    self.followers_for_show.includes(:alliance)
  end
  def followees_for_friends
    self.followees_for_show.includes(:alliance)
  end
  def friends_ids
    out_array = self.followees_relation(Profile).pluck(:id)
    self.followers_relation(Profile).pluck(:id).each do |i|
      out_array << i
    end
    return out_array
  end
  # profiles can like things
  acts_as_liker
  #profiles can mention and be mentioned in posts
  acts_as_mentionable
  acts_as_mentioner
  #note that the mentioned locations must have the acts_as_mentioner trait
  def self.notify_mentions_comment(mentioner_id,mentioned_ids, comment_id)
    mentioner = Profile.find mentioner_id
    mentioner.notify_mentions_comment(mentioned_ids, comment_id)
  end
  def notify_mentions_comment(mentioned_ids, comment_id)
    mentioner = self
    comment = Comment.find comment_id
    mentioneds = Profile.where{id.in mentioned_ids}
    link_location = ActionController::Base.helpers.link_to(comment.commentable_name, polymorphic_path(comment.commentable))
    link_mentioner = ActionController::Base.helpers.link_to(mentioner.name, Rails.application.routes.url_helpers.profile_path(mentioner.id))

    mentioneds.each do |mentioned|
      comment.mention!(mentioned)
      link_mentioned = ActionController::Base.helpers.link_to(mentioned.name, Rails.application.routes.url_helpers.profile_path(mentioned.id))
      #add to mentioned's timeline.
      TimelineEntry.post_to mentioned, {
          more: '',
          more_aggregate: '',
          subject: "was mentioned by #{link_mentioner} on #{link_location}",
          subject_aggregate: "was mentioned",
          aggregate_type: "mentioned",
          aggregate_type_2: "#{mentioner.id}_on_comment_#{comment.id}",
          aggregate_text: "#{link_mentioner} mentioned #{link_mentioned} on #{link_location} <br />",
      }

      #add to mentionier's timeline
      TimelineEntry.post_to mentioner, {
          more: '',
          more_aggregate: '',
          subject: "mentioned #{link_mentioned} on #{link_location}",
          subject_aggregate: "mentioned people",
          aggregate_type: "mentioner",
          aggregate_type_2: "#{mentioned.id}_on_comment_#{comment.id}",
          aggregate_text: "#{link_mentioner} mentioned #{link_mentioned} on #{link_location} <br />",
      }
    end
    #notify mentioned
    subject = "#{mentioner.name} has mentioned you in a comment on #{comment.commentable_name}."
    body = "Hey, <br /> #{link_mentioner} has mentioned you in a comment on  #{link_location} page. <br /> Happy Computing! <br />  - theSkyNet"

    aggregation_subject = "You have been mentioned in %COUNT% new comments"
    aggregation_body = "Hey, <br /> You have been mentioned in the following %COUNT% new comments. <br /> By:"
    aggregation_text = "on #{link_location} by #{link_mentioner}<br />"
    ProfileNotification.notify_all(mentioneds,subject,body,comment,true, aggregation_text,'mention')
    ProfileNotification.aggrigate_by_class(Comment.to_s,aggregation_subject,aggregation_body,'mention')
  end

  has_many :timeline_entries, as: :timelineable
  def own_timeline
    TimelineEntry.get_timeline('Profile' => [self.id])
  end
  def followees_timeline
    timeline_hash = {
      'Profile' => followees_relation(Profile).pluck(:id),
      'Alliance' => likeables_relation(Alliance).pluck(:id),
    }
    timeline_hash['Alliance'] << alliance_id unless alliance_id.nil?
    TimelineEntry.get_timeline(timeline_hash)

  end

  def self.timeline_like(profile_id,object_class,object_id)
    object = object_class.constantize.find object_id
    profile = Profile.find profile_id
    profile.timeline_like object
    if object.class == Comment
      Comment.delay.like_comment(object.id,profile.id)
    end
  end
  def timeline_like(object)

    if object.class == Comment
      object_name = "a comment on #{object.commentable_name}"
      link_to_object = ActionController::Base.helpers.link_to(object_name, polymorphic_path(object.commentable))
    else
      if object.respond_to? :name
        object_name = object.name
      elsif object.respond_to? :title
        object_name = object.title
      else
        object_name = object.class.to_s
      end
      link_to_object = ActionController::Base.helpers.link_to(object_name, polymorphic_path(object))
    end
    link_profile = ActionController::Base.helpers.link_to(self.name, Rails.application.routes.url_helpers.profile_path(self.id))
    TimelineEntry.post_to self, {
        more: '',
        more_aggregate: '',
        subject: "liked #{link_to_object}",
        subject_aggregate: "liked #{object.class.to_s.pluralize}",
        aggregate_type: "like_#{object.class.to_s}",
        aggregate_type_2: object.id,
        aggregate_text: "#{link_profile} likes: #{link_to_object} <br />",
    }
  end

  def  self.for_show(id)
    p = includes(:general_stats_item => [:boinc_stats_item, :nereus_stats_item]).includes(:trophies, :user,:alliance).find(id)
    (p.user.invitation_sent_at.nil? || !p.user.invitation_accepted_at.nil?) ? p : nil
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
    return 'None' if country.nil? || country == ''
    out = ::CountrySelect::COUNTRIES[country.downcase]
    out = country if out.nil?
    return out
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
    temp_name
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


  def join_alliance(alliance, update_pogs = true, msg = 'no msg given')
    if self.alliance != nil || (alliance.pogs_team_id > 0 && self.general_stats_item.boinc_stats_item.nil?)
      false
    else
      self.alliance = alliance
      AllianceMembers.join_alliance(self,alliance, msg)
      self.save
      if alliance.pogs_team_id > 0 && update_pogs
        BoincRemoteUser.delay.join_team self.general_stats_item.boinc_stats_item.boinc_id, alliance.pogs_team_id
      end
    end
  end

  def leave_alliance(update_pogs = true, msg = 'no msg given')
    if self.alliance == nil
      false
    else
      item = self.alliance_items.where{(leave_date == nil) & (alliance_id == my{self.alliance.id})}.first
      item.leave_alliance(self, msg)
      if self.alliance.pogs_team_id > 0 && update_pogs
        BoincRemoteUser.delay.leave_team self.general_stats_item.boinc_stats_item.boinc_id
      end
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
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
  end

  def avatar_edit_url
    "https://en.gravatar.com/emails/"
  end


  def trophies_by_set
    sets = trophy_sets.order("trophy_sets.main DESC").uniq
    all_trophies = trophies.order("profiles_trophies.created_at DESC, trophies.credits DESC").group_by{|t| t.trophy_set_id}
    sets.each do |set|
      set.profile_trophies = all_trophies[set.id]
    end
    sets
  end

  def trophies_by_priority
    self.trophies.
        select('trophies.*').
        select{coalesce(profiles_trophies.priority,trophies.priority,trophy_sets.priority,0).as(trophy_priority)}.
        joins(:trophy_set).
        order('trophy_priority desc')
  end

  def trophies_by_priority_set
    sets = trophy_sets.order("trophy_sets.main DESC").uniq
    all_trophies = trophies.
        select('trophies.*').
        select{coalesce(profiles_trophies.priority,trophies.priority,trophy_sets.priority,0).as(trophy_priority)}.
        joins(:trophy_set).
        order('trophy_priority desc').
        group_by{|t| t.trophy_set_id}
    sets.each do |set|
      set.profile_trophies = all_trophies[set.id]
    end
    sets
  end

  def has_trophy(trophy)
    ProfilesTrophy.where{(profile_id == my{self.id}) & (trophy_id == my{trophy.id})}.count > 0
  end



  def is_science_user?
    science_portal = SciencePortal.where{slug == "galaxy_private"}.first
    if science_portal.nil?
      return false
    else
      return science_portal.check_access(self.id)
    end
  end

  def is_pogs?
    !self.general_stats_item.boinc_stats_item.nil?
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



  def self.notify_follow(id, follower_id)
    self.find(id).notify_follow(follower_id)
  end
  def notify_follow(follower_id)
    follower = Profile.find follower_id
    return false if follower.nil?

    subject = "#{follower.name} has followed your profile."
    link_follower = ActionController::Base.helpers.link_to(follower.name, Rails.application.routes.url_helpers.profile_path(follower.id))
    body = "Hey #{name}, <br /> #{link_follower} has followed your profile. <br /> Happy Computing! <br />  - theSkyNet"

    aggregation_subject = "Your profile has been followed by %COUNT% users."
    aggregation_body = "Hey #{name}, <br /> Your profile has been followed by %COUNT% users:"
    aggregation_text = "#{link_follower} <br />"
    ProfileNotification.notify_with_aggrigation(self,subject,body,aggregation_subject,aggregation_body,'class_id',self, aggregation_text, 'follow')
  end

  mapping do
    indexes :name, :as => 'name', analyzer: 'snowball', tokenizer: 'nGram'
    indexes :id
  end

  def friends_search(name)
    ids = self.friends_ids
    Profile.name_search(name, ids)
  end

  def self.name_search(name, ids)
    tire.search(
        page: 1,
        per_page: 10,
        load: {
            include: [:alliance, :user]
        }
    ) do
      query do
        boolean(:minimum_number_should_match => 1) do
          should {match :name, name}
          should {prefix :name, name}
        end
      end
      filter  :terms, id: ids
      facet('id') { terms :id }
    end
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
