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
  #this function finds a new home free of enemies ready for an excited new player
  #accepts a location in the form of {x:1,y:1,z:1} that the system will try to award as the home
  def self.find_new_home(location = nil)
    if location
      quadrant_pool =  TheSkyMap::Quadrant.where{(x==location[:x]) && (y==location[:y]) && (z==location[:z])}
    else
      quadrant_pool = TheSkyMap::Quadrant.where{z==1}
    end
    suitable_type_ids = TheSkyMap::QuadrantType.where{suitable_for_home == true}.pluck(:id)
    suitable_relation = quadrant_pool. #only interested in layer 1 for now
      where{owner_id == nil}. #only interested in unowned area's
      where{the_sky_map_quadrant_type_id.in suitable_type_ids} #only interested in certain quadrant types

    suitable_with_ships_ids =   suitable_relation.joins(:the_sky_map_ships).pluck("#{TheSkyMap::Quadrant.table_name}.id")
    suitable_quadrants = suitable_relation.where{id.not_in suitable_with_ships_ids}
    quadrant = suitable_quadrants.sample #return a random quadrant from the suitable ones

    if quadrant.nil? && location
      quadrant = self.find_new_home(nil)
    end
    quadrant
  end
  def update_total_income
    new_total= self.the_sky_map_bases.joins{the_sky_map_base_upgrade_type}.
        sum("#{TheSkyMap::BaseUpgradeType.table_name}.income").to_i
    self.total_income = new_total
    new_total
  end
  def update_total_score_with_save
    update_total_income
    save
    self.owner.update_total_income unless owner_id.nil?
    owner.save unless owner_id.nil?
  end
  def update_total_score
    new_total= self.the_sky_map_bases.joins{the_sky_map_base_upgrade_type}.
        sum("#{TheSkyMap::BaseUpgradeType.table_name}.score").to_i
    new_total = new_total + self.the_sky_map_quadrant_type.score
    self.total_score = new_total
    new_total
  end
  def update_total_score_with_save
    self.update_total_score
    self.save
    self.owner.update_total_score unless self.owner_id.nil?
    self.owner.save unless self.owner_id.nil?
  end
  def update_totals
    update_total_income
    update_total_score
    save
    owner.update_total_income unless owner_id.nil?
    owner.update_total_score unless owner_id.nil?
    owner.save unless owner_id.nil?
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
  def self.for_show_mini(player)
    if player.options['fog_of_war_on']
      includes(:the_sky_map_quadrant_type).
      joins("INNER JOIN
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
  def surrounding_quadrants_move
    TheSkyMap::Quadrant.where{z == my{self.z}}.where{
      ((x == my{self.x}) & ((y == my{self.y-1}) | (y == my{self.y+1}))) |
      ((y == my{self.y}) & ((x == my{self.x-1}) | (x == my{self.x+1})))
    }
  end
  def surrounding_quadrants
    TheSkyMap::Quadrant.
        where{(x <= my{self.x+1}) & (x >= my{self.x-1})}.
        where{(y <= my{self.y+1}) & (y >= my{self.y-1})}.
        where{(z <= my{self.z}) & (z >= my{self.z})}.
        where{((x != my{self.x}) | (y != my{self.y}) | (z != my{self.z})) }
  end

  #randomly generates a new quadrant at the given location
  #if one already exisits do nothing
  def self.generate_new(x,y,z, chance_table = nil)
    #check for existing quadrant
    return unless self.at_pos(x,y,z).nil?

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
    new_quadrant.update_total_income
    new_quadrant.update_total_score
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

  #performs the capture of an unowned quadrant for the player
  def capture(player)
    #check that quadrant is unowned
    return false unless self.owner_id.nil?
    #update owner information
    self.owner = player
    self.save
    self.owner.update_totals
    return true
  end

  #performs the stealing an owned quadrant for the player
  def steal(player)
    return false unless self.is_stealable?(player)
    old_owner = self.owner
    self.owner = player
    self.save
    player.update_totals
    old_owner.update_totals
    return true
  end
  def has_bases?
    num_of_built_bases > 0
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

  def is_stealable?(actor)
    #can't steal an unowned quadrant or one you already own
    return false if owner_id.nil? || owner_id == actor.id
    #can't steal a quadrant if it has a base defending it
    return false if has_bases?
    #can't steal someones home base. home bases are protected by magic
    return false if owner.home_id == self.id
    return true
  end
  def has_attackable_base?(actor)
    #can't attack an unowned quadrant or one you already own
    return false if owner_id.nil? || owner_id == actor.id
    #can't attack a base if it dosn't have one
    return false unless has_bases?
    return true
  end
  def has_attackable_ships?(actor)
    attackable_ships(actor).count > 0
  end
  def attackable_ships(actor)
    self.the_sky_map_ships.where{the_sky_map_ships.the_sky_map_player_id != my{actor.id}}
  end
end
