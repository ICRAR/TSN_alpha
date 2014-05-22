class TheSkyMap::Ship < ActiveRecord::Base
  attr_accessible :the_sky_map_quadrant_id, :the_sky_map_player_id, :the_sky_map_ship_type_id, as: [:admin]

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"
  belongs_to :the_sky_map_ship_type, :class_name => 'TheSkyMap::ShipType', foreign_key: "the_sky_map_ship_type_id"
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_quadrant_id", primary_key: "the_sky_map_quadrant_id"

  def self.for_show(ship_id)
    self.find(ship_id)
  end

  def self.for_index(player)
    TheSkyMap::Ship.joins{the_sky_map_players_quadrants}.
      where{the_sky_map_players_quadrants.the_sky_map_player_id == player.id}.
      where{the_sky_map_players_quadrants.explored == true}
  end

end
