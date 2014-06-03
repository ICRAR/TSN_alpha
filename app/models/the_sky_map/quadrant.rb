class TheSkyMap::Quadrant < ActiveRecord::Base
  attr_accessible :x, :y, :z, :the_sky_map_quadrant_type_id, as: [:admin]

  belongs_to :the_sky_map_quadrant_type, :class_name => 'TheSkyMap::QuadrantType', foreign_key: "the_sky_map_quadrant_type_id"
  belongs_to :owner, :class_name => 'TheSkyMap::Player', :foreign_key => 'owner_id'

  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_quadrant_id"
  has_many :the_sky_map_players, :class_name => 'TheSkyMap::Player', through: :the_sky_map_players_quadrants

  has_many :the_sky_map_ships, :class_name => 'TheSkyMap::Ship', foreign_key: "the_sky_map_quadrant_id"
  has_many :the_sky_map_bases, :class_name => 'TheSkyMap::Base', foreign_key: "the_sky_map_quadrant_id"


  validates_uniqueness_of :x, scope: [:y, :z]
  validates_presence_of :the_sky_map_quadrant_type_id
  def self.within_range(x_min,x_max,y_min,y_max,z_min,z_max)
    where{(z >= z_min) & (z <= z_max)}.
      where{(y >= y_min) & (y <= y_max)}.
      where{(x >= x_min) & (x <= x_max)}.
      order([:z,:y,:x])
  end
  def self.for_show(player)
    if player.options['fog_of_war_on']
      includes(:the_sky_map_quadrant_type).
      includes(:the_sky_map_ships).
          joins("LEFT OUTER JOIN
      the_sky_map_players_quadrants ON the_sky_map_players_quadrants.the_sky_map_quadrant_id = the_sky_map_quadrants.id and
      the_sky_map_players_quadrants.the_sky_map_player_id = #{player.id}").
          select('the_sky_map_quadrants.*').
          select{the_sky_map_players_quadrants.explored.as('explored')}
    else
      includes(:the_sky_map_quadrant_type).
          includes(:the_sky_map_ships).
          select('the_sky_map_quadrants.*').
          select('1 as explored')
    end
  end
  def self.at_pos(x_pos,y_pos,z_pos)
    where{(x == x_pos) & (y == y_pos) & (z == z_pos)}.first
  end
  def surrounding_quadrants
    TheSkyMap::Quadrant.
        where{(x <= my{self.x+1}) & (x >= my{self.x-1})}.
        where{(y <= my{self.y+1}) & (y >= my{self.y-1})}.
        where{(z <= my{self.z}) & (z >= my{self.z})}.
        where{((x != my{self.x}) | (y != my{self.y}) | (z != my{self.z})) }
  end

  #randomly generates a new quadrant at the given loction
  #if one already exisits do nothing
  def self.generate_new(x,y,z, chance_table = nil)
    #check for existing quadrant
    return if self.at_pos(x,y,z).exists?

    #determine type table
    chance_table ||= TheSkyMap::QuadrantType.generation_chance_table

    #randomly determine type
    type_id = TheSkyMap::QuadrantType.pick_random_id(chance_table)
    #create quadrant
    new_quadrant = self.new({
      x: x,
      y: y,
      z: z,
      the_sky_map_quadrant_type_id: type_id
    }, as: :admin)
    new_quadrant.save

  end
  def self.generate_new_area(x_range, y_range, z_range, chance_table = nil)
    #determine type table
    chance_table ||= TheSkyMap::QuadrantType.generation_chance_table
    x_range.each do |x|
      y_range.each do |y|
        z_range.each do |z|
          self.generate_new(x,y,z, chance_table)
        end
      end
    end
  end

  def distance_to(to_x,to_y,to_z)
    x2 = ((to_x - x).abs)**2
    y2 = ((to_y - y).abs)**2
    z2 = ((to_z - z).abs)**2
    Math.sqrt(x2 + y2 + z2)
  end

  def capture(player)
    #check that quadrant is unowned
    return false unless self.owner_id.nil?
    #update owner information
    self.owner = player
    self.save
    return true
  end

  def num_of_built_bases
    the_sky_map_bases.count
  end
  def bases_allowed(actor)
    if ((actor.id == owner_id) && (the_sky_map_quadrant_type.num_of_bases > num_of_built_bases))
      the_sky_map_quadrant_type.the_sky_map_base_upgrade_types.where{parent_id == nil}
    else
      nil
    end
  end
end
