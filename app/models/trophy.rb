class Trophy < ActiveRecord::Base
  attr_accessible :credits, :desc, :title, :image, as: :admin
  has_attached_file :image
  has_many :profiles_trophies, :dependent => :delete_all, :autosave => true
  has_many :profiles, :through => :profiles_trophies
  validates_presence_of  :desc, :title, :image

 #ToDo add a method to add a new trophy to existing users

  def self.next_trophy(cr)
    tr = Trophy.where("credits >= ?",cr).order("credits ASC").first
  end
  def self.last_trophy(cr)
    tr =  Trophy.where("credits <= ?",cr).order("credits DESC").first
  end
end
