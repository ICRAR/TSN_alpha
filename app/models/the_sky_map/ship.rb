class TheSkyMap::Ship < TheSkyMap::BaseModel
  attr_accessible :the_sky_map_quadrant_id, :the_sky_map_player_id, :the_sky_map_ship_type_id, as: [:admin]

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"
  belongs_to :the_sky_map_ship_type, :class_name => 'TheSkyMap::ShipType', foreign_key: "the_sky_map_ship_type_id"
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_quadrant_id", primary_key: "the_sky_map_quadrant_id"

  def self.for_show(player,ship_id)
    self.fog_of_war(player).find(ship_id)
  end

  def self.for_index(player)
    TheSkyMap::Ship.fog_of_war(player).all
  end
  def self.fog_of_war(player)
    if player.options['fog_of_war_on']
      TheSkyMap::Ship.joins{the_sky_map_players_quadrants}.
          where{the_sky_map_players_quadrants.the_sky_map_player_id == player.id}.
          where{the_sky_map_players_quadrants.explored == true}
    else
      TheSkyMap::Ship
    end
  end


  #actions
  acts_as_actionable
  def actions_list
    ['move', 'capture']
  end
  def capture_options(actor)
    quadrant = the_sky_map_quadrant
    allowed = quadrant.owner_id.nil?
    action_name = "capture_#{quadrant.x}_#{quadrant.y}_#{quadrant.z}".to_sym
    {action_name => {
        action: 'capture',
        name: "Capture the Quadrant (#{quadrant.x}, #{quadrant.y}, #{quadrant.z})",
        cost: 10,
        duration: 60,
        options: {x: quadrant.x, y: quadrant.y, z: quadrant.z},
        allowed: allowed
    }}
  end
  def perform_capture(opts)
    quadrant = TheSkyMap::Quadrant.at_pos(opts[:x],opts[:y], opts[:z])
    #check if ship is still in the correct quadrant
    return false unless quadrant == the_sky_map_quadrant
    #check that the quadrant is still unoccupided
    return false unless quadrant.owner_id.nil?
    #capture quadrant
    outcome = quadrant.capture(the_sky_map_player)
    #push changes with faye
    PostToFaye.request_update('quadrant',[quadrant.id])
    return outcome
  end

  def move_options(actor)
    home = the_sky_map_player.home
    surrounding_quadrants = the_sky_map_quadrant.surrounding_quadrants
    available_moves = {}
    surrounding_quadrants.each do |quadrant|
      opt = "move_#{quadrant.x}_#{quadrant.y}_#{quadrant.z}".to_sym
      distance_to_home = quadrant.distance_to(home.x,home.y,home.z)
      cost = 10 * distance_to_home
      available_moves[opt] = {
          action: 'move',
          name: "Move to Quadrant (#{quadrant.x}, #{quadrant.y}, #{quadrant.z})",
          cost: cost,
          duration: 60,
          options: {x: quadrant.x, y: quadrant.y, z: quadrant.z},
          allowed: true
      }
    end
    available_moves
  end
  def perform_move(opts)

    quadrant = TheSkyMap::Quadrant.at_pos(opts[:x],opts[:y], opts[:z])
    #check if the move is allowed
    #ToDo return false if move is not allowed
    #move
    old_quadrant = self.the_sky_map_quadrant
    self.the_sky_map_quadrant = quadrant
    self.save

    #explore
      self.the_sky_map_player.explore_quadrant(quadrant)
    #force update to open quadrants
    quadrant_ids = quadrant.surrounding_quadrants.pluck(:id)
    quadrant_ids << old_quadrant.id
    PostToFaye.request_update('quadrant',quadrant_ids)
    #force update to open ship
    PostToFaye.request_update('ship',[self.id])
    return true
  end
end
