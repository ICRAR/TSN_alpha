class TrophySet < ActiveRecord::Base
  attr_accessible :name, :set_type, :main, as: :admin
  attr_accessor :profile_trophies
  has_many :trophies

  def set_type_enum
    ['credit_active','credit_inactive','custom']
  end

end
