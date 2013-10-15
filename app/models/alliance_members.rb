class AllianceMembers < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  attr_accessible :join_date, :leave_credit, :leave_date, :start_credit, :as => :admin
  belongs_to :alliance
  belongs_to :profile

  def self.for_alliance_show(alliance_id)
    joins(:profile => [:general_stats_item]).
        select("alliance_members.*, (alliance_members.leave_credit-IFNULL(alliance_members.start_credit,0)) as credit_contributed, general_stats_items.rank as rank, general_stats_items.total_credit as credits").
        where{alliance_members.alliance_id == alliance_id}.order("credit_contributed DESC").includes(:profile => :user)
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

  #A user should be notifed whenever a they join or leave an alliance. We will also notify the alliance leader.
  has_many :notifications, foreign_key: :notified_object_id, conditions: {notified_object_type: 'AllianceMembers'}, dependent: :destroy
  after_commit :create_notification_join, on: :create
  after_commit :create_notification_leave, on: :update

  def create_notification_join
    AllianceMembers.delay.create_notification_join(self.id)
  end
  def create_notification_leave
    AllianceMembers.delay.create_notification_leave(self.id) unless leave_date.nil?
  end

  def self.create_notification_join(id)
    am = AllianceMembers.find id

    Activity.track(am.profile, "joined", am.alliance)

    #send to member
    subject = "Welcome to the alliance, #{am.alliance.name}"
    link_alliance = ActionController::Base.helpers.link_to(am.alliance.name, Rails.application.routes.url_helpers.alliance_path(am.alliance))
    body = "Welcome #{am.profile.name} \nThank you for joining the #{link_alliance} alliance. \n Happy Computing! \n  - theSkyNet"
    am.profile.notify(subject, body, am)

    #send to leader unless you are the leader
    leader = am.alliance.leader
    unless leader.nil? || leader.id == am.profile.id
      subject = "#{am.profile.name} has joined your Alliance"
      link_profile = ActionController::Base.helpers.link_to(am.profile.name, Rails.application.routes.url_helpers.profile_path(am.profile))
      body = "#{link_profile} is eager to help and has joined the #{link_alliance} alliance. \n Happy Computing! \n  - theSkyNet"
      leader.notify(subject, body, am)
    end
  end
  def self.create_notification_leave(id)
    am = AllianceMembers.find id

    #send to member
    subject = "Goodbye from, #{am.alliance.name}"
    credits = am.leave_credit.to_i - am.start_credit.to_i
    link_alliance = ActionController::Base.helpers.link_to(am.alliance.name, Rails.application.routes.url_helpers.alliance_path(am.alliance))
    body = "Thank your for your help and contribution to the #{link_alliance} alliance. \n Over your time as a member you have contributed #{credits} credits \n Happy Computing! \n  - theSkyNet"
    am.profile.notify(subject, body, am)

    #send to leader
    leader = am.alliance.leader
    unless leader.nil?
      subject = "#{am.profile.name} as left your Alliance"
      link_profile = ActionController::Base.helpers.link_to(am.profile.name, Rails.application.routes.url_helpers.profile_path(am.profile))
      body = "#{link_profile} has left the #{link_alliance} alliance. \n During their time as a member they contributed #{credits} credits \n Happy Computing! \n  - theSkyNet"
      leader.notify(subject, body, am)
    end
  end

end
