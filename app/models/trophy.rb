class Trophy < ActiveRecord::Base
  attr_accessible :credits, :desc, :title, :image, :hidden, as: :admin
  has_attached_file :image
  has_many :profiles_trophies, :dependent => :delete_all, :autosave => true
  has_many :profiles, :through => :profiles_trophies
  validates_presence_of  :desc, :title, :image

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
    (self.hidden == true && !trophy_ids.include?(self.id))
  end


 #ToDo add a method to add a new trophy to existing users

  def self.next_trophy(cr)
    tr = Trophy.where("credits >= ?",cr).order("credits ASC").first
  end
  def self.last_trophy(cr)
    tr =  Trophy.where("credits <= ?",cr).order("credits DESC").first
  end
end
