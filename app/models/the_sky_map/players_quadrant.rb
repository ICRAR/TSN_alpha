class TheSkyMap::PlayersQuadrant < ActiveRecord::Base
  attr_accessible :explored, as: [:admin]
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"
  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  validates_uniqueness_of :the_sky_map_player_id, :scope => :the_sky_map_quadrant_id
end
