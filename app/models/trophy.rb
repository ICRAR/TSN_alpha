class Trophy < ActiveRecord::Base
  attr_accessible :credits, :desc, :title, :image, as: :admin
  has_attached_file :image
  has_and_belongs_to_many :profiles
  validates_presence_of  :desc, :title, :image


end
