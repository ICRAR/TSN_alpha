class ScienceLink < ActiveRecord::Base
  attr_accessible :name, :url, :science_portal_id, as: :admin
  belongs_to :science_portal

end
