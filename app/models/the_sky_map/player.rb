class TheSkyMap::Player < ActiveRecord::Base
  attr_accessible :rank, :score, :spent_points, :total_points, as: [:admin]

  belongs_to :profile
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_player_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', :through => :the_sky_map_players_quadrants
  has_many :the_sky_map_ships, :class_name => 'TheSkyMap::Ship', foreign_key: "the_sky_map_player_id"
  has_many :own_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "owner_id"

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

  #options
  def options_without_default
    opt = self[:options] || '{}'
    begin
      opt_hash = JSON.parse opt
    rescue TypeError, JSON::ParserError
      opt_hash = {}
    end
  end
  def self.options_default
    {
        'fog_of_war_on' => true
    }
  end
  def options
    TheSkyMap::Player.options_default.merge options_without_default
  end
  def set_options(hash)
    new_hash = options_without_default.merge hash
    self.options =  new_hash.to_json
  end
  def reset_option(key)
    new_hash = options_without_default
    new_hash.delete key
    self.options =  new_hash.to_json
  end

  #actor methods
  acts_as_actor
  def currency_available
    (total_points - spent_points)
  end
  def deduct_currency(value)
    self.class.where{id == self.id}.update_all("spent_points = spent_points + #{value.to_i}" )
  end
  def refund_currency(value)
    self.class.where{id == self.id}.update_all("spent_points = spent_points - #{value.to_i}" )
  end
end
