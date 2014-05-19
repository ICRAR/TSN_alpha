class TheSkyMap::ShipType < ActiveRecord::Base
  attr_accessible :attack, :desc, :health, :name, :speed, as: [:admin]
  validates_presence_of :attack, :desc, :health, :name, :speed

  has_many :the_sky_map_ships, :class_name => 'TheSkyMap::Ship', foreign_key: "the_sky_map_ship_type_id"
end
