class AllianceMembers < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  attr_accessible :join_date, :leave_credit, :leave_date, :start_credit, :as => :admin
  belongs_to :alliance
  belongs_to :profile

  scope :joins_gsi, joins{'INNER JOIN general_stats_items ON general_stats_items.profile_id = alliance_members.profile_id'}
  scope :current, where{leave_date == nil}


  def self.for_alliance_show(alliance_id)
    members = joins(:profile => [:general_stats_item]).
        select("alliance_members.*, (alliance_members.leave_credit-IFNULL(alliance_members.start_credit,0)) as credit_contributed, general_stats_items.rank as rank, general_stats_items.total_credit as credits").
        where{alliance_members.alliance_id == alliance_id}.order("credit_contributed DESC").includes(:profile => :user)
    members.each do |m|
      m.rank ||= '-'
    end
    members
  end
  def total_credits
    leave_credit-start_credit
  end
  def days_in_alliance
    leave_day = leave_date ? leave_date : Time.now
     ((leave_day - join_date)/86400).round
  end

  def start_credit
    self[:start_credit].to_i
  end
  def leave_credit
    self[:leave_credit].to_i
  end

  #functions for creating new alliance_member items
  #regular join alliance function, ie user clicks join alliance
  def self.join_alliance(profile, alliance, msg)
    item = AllianceMembers.new
    item.join_date = Time.now
    item.start_credit = profile.general_stats_item.total_credit
    item.start_credit ||= 0
    item.leave_credit = profile.general_stats_item.total_credit
    item.leave_credit ||= 0
    item.leave_date = nil
    item.log_msg(msg)

    profile.alliance_items << item
    alliance.member_items << item

    item.save

    AllianceMembers.delay.create_notification_join(item.id)
    item
  end
  #regular leave alliance function ie user clicks leave alliance
  def leave_alliance(profile, msg)
    self.log_msg(msg)
    self.leave_alliance_without_notification(profile)
    AllianceMembers.delay.create_notification_leave(self.id)
  end
  def leave_alliance_without_notification(profile)
    self.log_msg('leave_alliance_without_notification called')
    self.leave_date = Time.now
    self.leave_credit = profile.general_stats_item.total_credit
    self.save
  end
  #synced with BOINC
  def self.join_alliance_from_boinc_from_start(profile,alliance)
    member = AllianceMembers.new
    member.alliance_id = alliance.id
    member.profile_id = profile.id
    member.join_date = alliance.created_at
    member.start_credit = 0
    member.leave_credit = profile.total_credit
    member.leave_credit ||= 0
    member.leave_date = nil
    member.log_msg('join_alliance_from_boinc_from_start')
    member.save
  end
  def self.join_alliance_from_boinc(profile,alliance,boinc_membership)
    m = boinc_membership
    #only create new record if the user is not already a member of that alliance
    #check if that user was recently a member of the same alliance within last day or is a current memeber
    last = profile.alliance_items.last
    if last != nil && last.leave_date.nil? && last.alliance_id == alliance.id
      #do nothing if the user is already a current member of that alliance
      member = last
    elsif last != nil && !last.leave_date.nil? && last.alliance_id == alliance.id && (m.timestamp - last.leave_date.to_i).abs < 1.day
      # then update existing record to re add member to alliance
      member = last
      member.leave_date = nil
      member.leave_credit = profile.general_stats_item.total_credit
      member.leave_credit ||= 0
      member.log_msg('join_alliance_from_boinc')
      member.save
    else
      #only create new record if the user is not already a member of that alliance
      #create new alliance member
      member = AllianceMembers.new
      member.alliance_id = alliance.id
      member.profile_id = profile.id
      member.join_date = Time.at(m.timestamp)
      member.start_credit = m.total_credit
      #if timestamp is within 1 day and the users local credit is higher than POGS credit use local credit
      if m.timestamp > 1.day.ago.to_i &&  profile.general_stats_item.total_credit.to_i > m.total_credit
        member.start_credit = profile.general_stats_item.total_credit
      end
      member.start_credit ||= 0
      member.leave_credit = profile.general_stats_item.total_credit

      member.leave_credit ||= 0
      member.leave_date = nil
      member.log_msg('join_alliance_from_boinc new record created')
      member.save
    end
    member
  end
  def self.leave_alliance_from_boinc(profile,alliance,boinc_membership)
    m = boinc_membership
    member = AllianceMembers.where{(alliance_id == my{alliance.id}) &
        (profile_id == my{profile.id}) &
        (leave_date == nil)
    }.first
    if member.nil? && (m.total_credit.to_i == 0 || !m.check_if_first)
      #can't find corresponding join entry
      #if total credit is 0 ignore, strange boinc condition dosn't matter anyone as they had 0 credit
      # or if this is not the first entry in the team delta table for that user, then this was most
      #   likely caused by a race condition between theskynet and BOINC so we can safely ignore it
    else
      if member.nil? && m.total_credit.to_i > 0
        #check to see if this is first teamdelta entry for that user

        #Team delta is a new feature to BOINC we must assume this member joined before that time
        #So create them a new member item starting with 0 credit
        member = AllianceMembers.new
        member.log_msg('No old record could be found, creating a new one')
        member.alliance_id = alliance.id
        member.profile_id = profile.id
        member.join_date = Time.at(m.timestamp)
        member.start_credit =0
      end

      #now make that member item leave the alliance
      member.leave_date = Time.at(m.timestamp)
      member.leave_credit = m.total_credit
      #if timestamp is within 1 day and the users local credit is higher than POGS credit use local credit
      if m.timestamp > 1.day.ago.to_i &&  profile.general_stats_item.total_credit.to_i > m.total_credit
        member.leave_credit = profile.general_stats_item.total_credit
      end
      member.leave_credit ||= 0
      member.log_msg('leave_alliance_from_boinc')
      member.save
    end
  end

  #A user should be notifed whenever a they join or leave an alliance. We will also notify the alliance leader.
  has_many :notifications, foreign_key: :notified_object_id, conditions: {notified_object_type: 'AllianceMembers'}, dependent: :destroy


  def self.create_notification_join(id)
    am = AllianceMembers.find id

    Activity.track(am.profile, "joined", am.alliance)

    #send to member
    subject = "Welcome to the alliance, #{am.alliance.name}"
    link_alliance = ActionController::Base.helpers.link_to(am.alliance.name, Rails.application.routes.url_helpers.alliance_path(am.alliance))
    body = "Welcome #{am.profile.name} <br /> Thank you for joining the #{link_alliance} alliance. <br /> Happy Computing! <br />  - theSkyNet"
    ProfileNotification.notify(am.profile,subject,body,am.alliance)

    #send to leader unless you are the leader
    leader = am.alliance.leader
    unless leader.nil? || leader.id == am.profile.id
      subject = "#{am.profile.name} has joined your Alliance"
      link_profile = ActionController::Base.helpers.link_to(am.profile.name, Rails.application.routes.url_helpers.profile_path(am.profile))
      body = "#{link_profile} is eager to help and has joined the #{link_alliance} alliance. <br /> Happy Computing! <br />  - theSkyNet"

      aggregation_subject = "%COUNT% people have joined your alliance"
      aggregation_body = "Hey #{leader.name}, <br /> The following %COUNT% people have joined your alliance, #{link_alliance}:"
      aggregation_text = "#{link_profile} <br />"
      ProfileNotification.notify_with_aggrigation(leader,subject,body,aggregation_subject,aggregation_body,'class_id',am.alliance, aggregation_text, 'join')

    end
  end
  def self.create_notification_leave(id)
    am = AllianceMembers.find id

    #send to member
    subject = "Goodbye from, #{am.alliance.name}"
    credits = am.leave_credit.to_i - am.start_credit.to_i
    link_alliance = ActionController::Base.helpers.link_to(am.alliance.name, Rails.application.routes.url_helpers.alliance_path(am.alliance))
    body = "Thank your for your help and contribution to the #{link_alliance} alliance. <br /> Over your time as a member you have contributed #{credits} credits <br /> Happy Computing! <br />  - theSkyNet"
    ProfileNotification.notify(am.profile,subject,body,am.alliance)



    #send to leader
    leader = am.alliance.leader
    unless leader.nil?
      subject = "#{am.profile.name} has left your Alliance"
      link_profile = ActionController::Base.helpers.link_to(am.profile.name, Rails.application.routes.url_helpers.profile_path(am.profile))
      body = "#{link_profile} has left the #{link_alliance} alliance. <br /> During their time as a member they contributed #{credits} credits <br /> Happy Computing! <br />  - theSkyNet"

      aggregation_subject = "%COUNT% people have left your alliance"
      aggregation_body = "Hey #{leader.name}, <br /> The following %COUNT% people have left your alliance, #{link_alliance}:"
      aggregation_text = "#{link_profile} <br />"
      ProfileNotification.notify_with_aggrigation(leader,subject,body,aggregation_subject,aggregation_body,'class_id',am.alliance, aggregation_text, 'leave')

    end
  end

  #doesn't save
  def log_msg(msg)
    self.log = '' if self.log.nil?
    self.log << "\n" unless self.log == ''
    self.log << "Updated: #{Time.now} :: #{msg}"
  end


end
