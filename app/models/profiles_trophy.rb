class ProfilesTrophy < ActiveRecord::Base
  belongs_to :profile
  belongs_to :trophy

end