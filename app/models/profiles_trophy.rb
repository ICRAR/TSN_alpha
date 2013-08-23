class ProfilesTrophy < ActiveRecord::Base
  belongs_to :profile
  belongs_to :trophy
  attr_accessible :profile_id, :trophy_id


end