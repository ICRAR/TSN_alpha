class TheSkyMap::Player < ActiveRecord::Base
  attr_accessible :rank, :score, :spent_points, :total_points, as: [:admin]

  belongs_to :profile
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_player_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', :through => :the_sky_map_players_quadrants
  has_many :the_sky_map_ships, :class_name => 'TheSkyMap::Ship', foreign_key: "the_sky_map_player_id"

  belongs_to :home, :class_name => 'TheSkyMap::Quadrant', :foreign_key => 'home_id'

  before_create :set_defaults
  def set_defaults
    rank = 0
    score = 0
    spent_points = 0
    total_points = 0
  end

  def explore_quadrant(quadrant)
    #check for current join model
    pq = self.the_sky_map_players_quadrants.where{the_sky_map_quadrant_id == quadrant.id}.first
    if pq.nil?
      self.add_quadrant quadrant
      pq = self.the_sky_map_players_quadrants.where{the_sky_map_quadrant_id == quadrant.id}.first
    end

    pq.explored = true
    pq.save

    new = quadrant.surrounding_quadrants
    new.each do |q|
      self.add_quadrant q
    end

  end

  def add_quadrant(quadrant)
    begin
      self.the_sky_map_quadrants << quadrant
    rescue ActiveRecord::RecordInvalid => e
      rails e unless e.message == 'Validation failed: The sky map player has already been taken'
    end
  end
end
