class ScienceLink < ActiveRecord::Base
  attr_accessible :name, :url, as: :admin
  belongs_to :science_portal

end
