class TheSkyMap::Ship < ActiveRecord::Base
  attr_accessible :the_sky_map_quadrant_id, :the_sky_map_player_id, :the_sky_map_ship_type_id, as: [:admin]

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"
  belongs_to :the_sky_map_ship_type, :class_name => 'TheSkyMap::ShipType', foreign_key: "the_sky_map_ship_type_id"

  def self.for_show(ship_id)
    self.find(ship_id)
  end
end
