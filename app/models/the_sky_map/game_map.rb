class TheSkyMap::GameMap < ActiveRecord::Base
  attr_accessible :x_min, :x_max, :y_min, :y_max

  has_many :the_sky_map_players, :class_name => 'TheSkyMap::Player', foreign_key: "game_map_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "game_map_id"
end
