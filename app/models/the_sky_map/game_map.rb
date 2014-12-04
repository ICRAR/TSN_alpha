class TheSkyMap::GameMap < ActiveRecord::Base
  attr_accessible :x_min, :x_max, :y_min, :y_max, as: [:default, :admin]

  has_many :the_sky_map_players, :class_name => 'TheSkyMap::Player', foreign_key: "game_map_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "game_map_id"

  #builds a new game map of size x and y
  def self.build_new(x,y)
    map = self.create({
      x_min: 1,
      x_max: x,
      y_min: 1,
      y_max: y
             })
    #map.build_tiles
  end
  def x_size
    x_max - x_min + 1
  end
  def y_size
    y_max - y_min + 1
  end
  #builds all the tiles for a new map
  def build_tiles
    x_range = (self.x_min..self.x_max)
    y_range = (self.y_min..self.y_max)
    TheSkyMap::Quadrant.generate_new_area(x_range, y_range, self.id)
  end
  #adds a new player to the map
  def add_player(profile)
    new_player = TheSkyMap::Player.build_new_player(self.id,profile)
    self.set_player_colour new_player

  end
  def set_player_colour(player)
    new_id = self.the_sky_map_players.maximum(:colour_id) || -1
    player.colour_id = new_id + 1
    player.save
  end
  def reset_all_player_colours
    self.the_sky_map_players.update_all(colour_id: nil)
    self.the_sky_map_players.each do |player|
      self.set_player_colour player
    end
  end
end
