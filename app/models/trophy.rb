class Trophy < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  attr_accessible :credits, :desc, :title, :image, :hidden, :trophy_set_id, :priority, as: [:default, :admin]
  has_attached_file :image, styles: {
      tiny: '40x',
      medium: '100x',
      large: '200x',
      base: '160x'
  }
  has_many :profiles_trophies, :dependent => :destroy, :autosave => true
  has_many :profiles, :through => :profiles_trophies
  belongs_to :trophy_set
  validates_presence_of  :desc, :title, :image, :trophy_set
  has_many :notifications, foreign_key: :notified_object_id, conditions: {notified_object_type: 'Trophy.class'}, dependent: :destroy


  scope :all_credit_active, joins(:trophy_set).
      where{trophy_sets.set_type =~ "credit_active"}.
      where("credits IS NOT NULL")
  scope :all_credit_active_plus_classic, joins(:trophy_set).
      where{(trophy_sets.set_type =~ "credit_active") | (trophy_sets.set_type =~ "credit_classic")}.
      where("credits IS NOT NULL")


  has_many :comments, as: :commentable
  attr_readonly :comments_count

  attr_accessor :profiles_count_store, :last_priority, :next_priority

  before_save :update_set_type
  def update_set_type
    self.set_type = self.trophy_set.set_type
  end

  def profiles_count
    self.profiles_count_store ||= self.profiles.joins(:general_stats_item).where{general_stats_item.power_user == false}.count
  end


  def desc(trophy_ids = nil)

    if self.hidden?(trophy_ids) == true
      "This description is a secret that you have yet to earn"
    else
      self[:desc]
    end
  end
  def show_credits(trophy_ids = nil)
    (self.hidden?(trophy_ids) == true) ? "-" : self.credits
  end

  def hidden?(trophy_ids = nil)
    (self.hidden == true && (trophy_ids.nil? || !trophy_ids.include?(self.id)))
  end

  def award_by_time(profiles = nil)
    profiles ||= Profile
    profiles = profiles.for_trophies
    .joins{user}
    .where{user.joined_at <= my{self.credits.days.ago}}
    self.award_to_profiles profiles
  end

  def award_by_credit(profiles = nil)
    profiles ||= Profile
    profiles = profiles.for_trophies
      .where{general_stats_items.total_credit >= my{self.credits}}
    self.award_to_profiles profiles
  end

  def award_by_leader_board(profiles = nil)
    profiles ||= Profile
    profiles = profiles.for_trophies
      .where{general_stats_items.rank <= my{self.credits}}
    self.award_to_profiles profiles
  end

  def award_by_galaxy_count(profiles = nil, user_galaxy_count_hash = nil)
    profiles ||= Profile
    GalaxyUser.profiles_in_batches_by_count(self.credits,profiles,user_galaxy_count_hash) do |ps|
      self.award_to_profiles ps
    end
  end

  def award_by_rac(profiles = nil)
    profiles ||= Profile
    profiles = profiles.for_trophies
      .where{general_stats_items.recent_avg_credit >= my{self.credits}}
    self.award_to_profiles profiles
  end

  #note this function skips active record
  def award_to_profiles(profiles)
    inserts = []
    update_profiles = nil
    if profiles.class == Profile
      update_profiles = Profile.where{(id == my{profiles.id}) & (sift :does_not_have_trophy, my{self.id})}.all
    elsif profiles.class == ActiveRecord::Relation
      update_profiles = profiles.where{sift :does_not_have_trophy, my{self.id}}.all
    end
    return if update_profiles.empty?
    update_profiles.each do |p|
      inserts.push("(#{self.id}, #{p.id}, '#{Time.now}', '#{Time.now}')")

    end

    if inserts != []
      sql = "INSERT INTO profiles_trophies (trophy_id , profile_id, created_at, updated_at) VALUES #{inserts.join(", ")}"
      db_conn = ActiveRecord::Base.connection
      db_conn.execute sql

      create_notification(update_profiles)
    end

  end

  def create_notification(profiles)
    Activity.track(profiles,'award',self)
    subject = "You have been awarded a new trophy, #{self.title}"
    link = link_to(self.title, Rails.application.routes.url_helpers.trophy_path(self))
    body = "Congratulations! <br /> You have been awarded a new trophy, #{link}. <br /> Thank you and happy computing! <br /> theSkyNet"
    aggregation_text = "#{link} <br />"
    profile_ids = profiles.map(&:id)
    ProfileNotification.notify_all_id_array(profile_ids,subject,body,self,true, aggregation_text)
  end
  def self.aggregate_notifications
    subject = "Wow! You have been awarded %COUNT% new trophies"
    body = "Congratulations! <br /> You have been awarded the following %COUNT% new trophies:"
    ProfileNotification.aggrigate_by_class(Trophy.to_s,subject,body)
  end


  def self.next_trophy(cr,classic = false)
    if classic == true
      tr = Trophy.all_credit_active_plus_classic.where("credits >= ?",cr).order("credits ASC").first
    else
      tr = Trophy.all_credit_active.where("credits >= ?",cr).order("credits ASC").first
    end
  end
  def self.last_trophy(cr,classic = false)
    if classic == true
      tr =  Trophy.all_credit_active_plus_classic.where("credits <= ?",cr).order("credits DESC").first
    else
      tr =  Trophy.all_credit_active.where("credits <= ?",cr).order("credits DESC").first
    end
  end


  rails_admin do
    field :credits
    field :priority
    field :desc do
      ckeditor true
    end
    field :title
    field :image
    field :hidden
    field :trophy_set
  end
end
