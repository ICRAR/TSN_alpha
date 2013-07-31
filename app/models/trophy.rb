class Trophy < ActiveRecord::Base
  attr_accessible :credits, :desc, :title, :image, :hidden, :trophy_set_id, as: :admin
  has_attached_file :image
  has_many :profiles_trophies, :dependent => :delete_all, :autosave => true
  has_many :profiles, :through => :profiles_trophies
  belongs_to :trophy_set
  validates_presence_of  :desc, :title, :image

  scope :all_credit_active, joins(:trophy_set).where{trophy_sets.set_type =~ "credit_active"}.where("credits IS NOT NULL")

  def desc(trophy_ids = nil)

    if trophy_ids == nil || self.hidden?(trophy_ids) == true
      "This description is a secret that you have yet to earn"
    else
      self[:desc]
    end
  end
  def show_credits(trophy_ids = nil)
    if trophy_ids == nil || self.hidden?(trophy_ids) == true
      "-"
    else
      self.credits
    end
  end
  def hidden?(trophy_ids)
    (self.hidden == true && (trophy_ids.nil? || !trophy_ids.include?(self.id)))
  end


 #ToDo add a method to add a new trophy to existing users

  def self.next_trophy(cr)
    tr = Trophy.all_credit_active.where("credits >= ?",cr).order("credits ASC").first
  end
  def self.last_trophy(cr)
    tr =  Trophy.all_credit_active.where("credits <= ?",cr).order("credits DESC").first
  end

  def self.handout_by_credit(trophies,main = true)
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
          trophy_index = trophy_index == nil ? -1: trophy_index
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
end
