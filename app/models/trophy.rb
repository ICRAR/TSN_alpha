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
    .where{DATEDIFF(now.func,user.joined_at) >= my{self.credits}}
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

  def award_by_galaxy_count(profiles = nil)
    profiles ||= Profile
    boinc_ids = 0
  end

  def award_by_rac(profiles = nil)
    profiles ||= Profile
    profiles = profiles.for_trophies
      .where{general_stats_items.recent_avg_credit >= my{self.credits}}
    self.award_to_profiles profiles
  end

  #not this function skips active record
  def award_to_profiles(profiles)
    inserts = []
    update_profiles = nil
    if profiles.class == Profile
      update_profiles = Profile.where{(id == my{profiles.id}) & (sift :does_not_have_trophy, my{self.id})}
    elsif profiles.class == ActiveRecord::Relation
      update_profiles = profiles.where{sift :does_not_have_trophy, my{self.id}}
    end
    return if update_profiles.empty?
    update_profiles.each do |p|
      inserts.push("(#{self.id}, #{p.id}, '#{Time.now}', '#{Time.now}')")

    end

    if inserts != []
      sql = "INSERT INTO profiles_trophies (trophy_id , profile_id, created_at, updated_at) VALUES #{inserts.join(", ")}"
      db_conn = ActiveRecord::Base.connection
      db_conn.execute sql

      #puts sql
    end
    create_notification(update_profiles)
  end

  def create_notification(profiles)
    Activity.track(profiles,'award',self)
    subject = "You have been awarded a new trophy, #{self.title}"
    link = link_to(self.title, Rails.application.routes.url_helpers.trophy_path(self))
    body = "Congratulations! \n You have been awarded a new trophy, #{link}. \n Thank you and happy computing! \n theSkyNet"
    Notification.notify_all(profiles,subject, body, self)
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

  #takes a list of trophies and awards them bassed on credit.
  #NOTE this function skips active record
  #main indicates that this is the main trophy group as represented by the progress bar on the users dashboard
  #this function should not be used
  def self.handout_by_credit(trophies,main = true)
    puts "depreciation:: use award_by_credit instead, its faster and better :)"
    all_trophies = trophies
    trophies_credit_only = trophies.pluck(:credits)

    #load all profiles with general stats data
    profiles = Profile.for_trophies

    #check through all profiles adding upsert where needed and adding new profiles_trophies items
    connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    table_name = :general_stats_items
    profiles_trophies_inserts = []
    Upsert.batch(connection,table_name) do |upsert|
      profiles.each do |profile|
        changed = false
        if main
          trophy_index  = trophies_credit_only.index(profile.last_trophy_credit_value.to_i)
          #check for new users with no existing trophy ie last_trophy_credit_value = 0
          trophy_index ||=  -1
        else
          trophy_index = -1
        end
        required_for_next = all_trophies[trophy_index+1].try(:credits)
        while required_for_next != nil && required_for_next.to_i < profile.credits.to_i
          changed = true
          trophy_index += 1
          #add values to profiles_trophies (trophy_id,profile_id)
          profiles_trophies_inserts.push("(#{all_trophies[trophy_index].id}, #{profile.id}, '#{Time.now}', '#{Time.now}')")
          required_for_next = all_trophies[trophy_index+1].try(:credits)
        end
        if changed && main
          upsert.row({:id => profile.stats_id}, :last_trophy_credit_value => all_trophies[trophy_index].credits, :updated_at => Time.now, :created_at => Time.now)
        end
      end

    end
    #add new rows to profiles_trophies
    if profiles_trophies_inserts != []
      sql = "INSERT INTO profiles_trophies (trophy_id , profile_id, created_at, updated_at) VALUES #{profiles_trophies_inserts.join(", ")}"
      db_conn = ActiveRecord::Base.connection
      db_conn.execute sql
      #print sql
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
