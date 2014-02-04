class Challenger < ActiveRecord::Base
  attr_accessible :score
  belongs_to :challenge
  belongs_to :entity, polymorphic: true


end
