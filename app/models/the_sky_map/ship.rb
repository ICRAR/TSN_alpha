class TheSkyMap::Ship < TheSkyMap::BaseModel
  attr_accessible :the_sky_map_quadrant_id, :the_sky_map_player_id, :the_sky_map_ship_type_id, as: [:admin]

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"
  belongs_to :the_sky_map_ship_type, :class_name => 'TheSkyMap::ShipType', foreign_key: "the_sky_map_ship_type_id"
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_quadrant_id", primary_key: "the_sky_map_quadrant_id"

  def self.for_show(player,ship_id)
    self.fog_of_war(player).find(ship_id)
  end

  def remaining_health
    self.the_sky_map_ship_type.health - self.damage
  end

  def self.for_index(player)
    TheSkyMap::Ship.fog_of_war(player).scoped
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

  def on_own_quadrant?
    the_sky_map_quadrant.owner_id == the_sky_map_player_id
  end
  def on_unowned_quadrant?
    the_sky_map_quadrant.owner_id == nil
    end
  def on_hostile_quadrant?
    !on_unowned_quadrant? && !on_own_quadrant?
  end

  #actions
  acts_as_actionable
  def default_actor
    the_sky_map_player
  end
  def actions_list
    ['move', 'capture', 'build_base', 'steal', 'attack_base', 'attack_ship']
  end
  def build_base_options(actor)
    return {} if !current_action.nil? && current_action.action == 'move'
    if the_sky_map_ship_type.can_build_bases?
      quadrant = the_sky_map_quadrant
      bases_allowed = quadrant.bases_allowed(actor)
      if bases_allowed.nil?
        {}
      else
        available_builds = {}
        bases_allowed.each do |base|
          action_name = "build_base_#{base.id}_at_#{quadrant.x}_#{quadrant.y}_#{quadrant.z}".to_sym
          available_builds[action_name] = {
                action: 'build_base',
                name: "Build a new '#{base.name}' base on (#{quadrant.x}, #{quadrant.y}, #{quadrant.z})",
                cost: base.cost,
                duration: base.duration,
                options: {base_upgrade_type_id: base.id,x: quadrant.x, y: quadrant.y, z: quadrant.z},
                allowed: true,
                icon: 'glyphicon-tower'
          }
        end
        available_builds
      end
    else
      {}
    end
  end
  def perform_build_base(options)
    return false unless the_sky_map_ship_type.can_build_bases?
    quadrant = the_sky_map_quadrant
    actor = the_sky_map_player
    new_base_type = quadrant.bases_allowed(actor).find(options[:base_upgrade_type_id])
    return false if new_base_type.nil?
    new_base = TheSkyMap::Base.first_base(quadrant,new_base_type)
    return false if new_base.nil?
    true

  end

  def steal_options(actor)
    #can't queue a steal action if the ship is currenly moving
    return {} if !current_action.nil? && current_action.action == 'move'
    quadrant = the_sky_map_quadrant
    if quadrant.is_stealable?(actor)
      action_name = "steal_#{quadrant.x}_#{quadrant.y}_#{quadrant.z}".to_sym
      {action_name => {
          action: 'steal',
          name: "Steal the Quadrant (#{quadrant.x}, #{quadrant.y})",
          cost: 500,
          duration: 1200,
          options: {x: quadrant.x, y: quadrant.y, z: quadrant.z},
          allowed: true,
          icon: 'glyphicon-remove-circle'
      }}
    else
      {}
    end
  end
  def perform_steal(opts)
    quadrant = TheSkyMap::Quadrant.at_pos(opts[:x],opts[:y], opts[:z])
    #check if ship is still in the correct quadrant
    return false unless quadrant.is_stealable?(the_sky_map_player)
    #capture quadrant
    outcome = quadrant.steal(the_sky_map_player)
    #push changes with faye
    PostToFaye.request_update('quadrant',[quadrant.id])
    PostToFaye.request_update('mini_quadrant',[quadrant.id])
    return outcome
  end

  def capture_options(actor)
    return {} if !current_action.nil? && current_action.action == 'move'
    quadrant = the_sky_map_quadrant
    if quadrant.owner_id.nil?
      action_name = "capture_#{quadrant.x}_#{quadrant.y}_#{quadrant.z}".to_sym
      {action_name => {
          action: 'capture',
          name: "Capture the Quadrant (#{quadrant.x}, #{quadrant.y})",
          cost: 10,
          duration: 60,
          options: {x: quadrant.x, y: quadrant.y, z: quadrant.z},
          allowed: true,
          icon: 'glyphicon-log-in'
      }}
    else
      {}
    end
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
    PostToFaye.request_update('mini_quadrant',[quadrant.id])
    return outcome
  end

  def move_options(actor)
    return {} if !current_action.nil? && current_action.action == 'move'
    home = the_sky_map_player.home

    surrounding_quadrants = the_sky_map_quadrant.surrounding_quadrants_move
    if on_hostile_quadrant?
      surrounding_quadrants = surrounding_quadrants.where{(owner_id == nil) | (owner_id == my{the_sky_map_player_id})}
    end
    available_moves = {}
    surrounding_quadrants.each do |quadrant|
      opt = "move_#{quadrant.x}_#{quadrant.y}_#{quadrant.z}".to_sym
      distance_to_home = quadrant.distance_to(home.x,home.y,home.z)
      cost = 10 * distance_to_home
      cost = cost.ceil
      dir = if quadrant.x == the_sky_map_quadrant.x
              quadrant.y > the_sky_map_quadrant.y ? 'down' : 'up'
            else
              quadrant.x > the_sky_map_quadrant.x ? 'right' : 'left'
            end
      available_moves[opt] = {
          action: 'move',
          name: "Move to Quadrant (#{quadrant.x}, #{quadrant.y})",
          cost: cost,
          duration: 600,
          options: {x: quadrant.x, y: quadrant.y, z: quadrant.z},
          allowed: true,
          icon: "glyphicon-arrow-#{dir}"
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
    explored_quadrants =  self.the_sky_map_player.explore_quadrant(quadrant)
    #force update to open quadrants
    full_update_quadrants =  [old_quadrant.id,quadrant.id]
    PostToFaye.request_update('quadrant',full_update_quadrants)

    player_id = self.the_sky_map_player_id
    PostToFaye.request_update_player_only('quadrant',(explored_quadrants - full_update_quadrants),[player_id])
    PostToFaye.request_update_player_only('mini_quadrant',explored_quadrants,[player_id])

    #force update to open ship
    PostToFaye.request_update('ship',[self.id])
    return true
  end

  def attack_base_options(actor)
    return {} if !current_action.nil? && current_action.action == 'move'
    quadrant = the_sky_map_quadrant

    if quadrant.has_attackable_base?(the_sky_map_player)
      available_bases = {}
      quadrant.the_sky_map_bases.each do |base|
        action_name = "attack_base_#{base.id}".to_sym
        available_bases[action_name] = {
            action: 'attack_base',
            name: "Attack the Base: #{base.name} (#{base.id})",
            cost: 100,
            duration: 60,
            options: {base_id: base.id},
            allowed: true,
            icon: 'glyphicon-screenshot'
        }
      end
      available_bases
    else
      {}
    end
  end
  def perform_attack_base(opts)
    base = TheSkyMap::Base.find(opts[:base_id])
    quadrant = base.the_sky_map_quadrant
    #check if ship is still in the correct quadrant
    return false unless quadrant == the_sky_map_quadrant

    #attack the base
    outcome = base.attacked(the_sky_map_player,the_sky_map_ship_type.attack)
    #push changes with faye
    if base.destroyed?
      PostToFaye.request_update('quadrant',[quadrant.id])
      PostToFaye.remove_model_delayed(base.id,'base')
    else
      PostToFaye.request_update('base',[base.id])
    end
    return outcome
  end
  def attack_ship_options(actor)
    return {} if !current_action.nil? && current_action.action == 'move'
    quadrant = the_sky_map_quadrant

    if quadrant.has_attackable_ships?(the_sky_map_player)
      available_ships = {}
      quadrant.attackable_ships(the_sky_map_player).each do |attacked_ship|
        action_name = "attack_ship_#{attacked_ship.id}".to_sym
        available_ships[action_name] = {
            action: 'attack_ship',
            name: "Attack the Ship: #{attacked_ship.id}",
            cost: 100,
            duration: 60,
            options: {ship_id: attacked_ship.id},
            allowed: true,
            icon: 'glyphicon-screenshot'
        }
      end
      available_ships
    else
      {}
    end
  end
  def perform_attack_ship(opts)
    attacked_ship = TheSkyMap::Ship.find(opts[:ship_id])
    quadrant = the_sky_map_quadrant

    #check if attacked ship is in the your quadrant
    #if not return true as you missed and thus forfeit your resources
    return true unless quadrant == attacked_ship.the_sky_map_quadrant

    #attack the base
    outcome = attacked_ship.attacked(the_sky_map_player,the_sky_map_ship_type.attack)
    #push changes with faye
    if attacked_ship.destroyed?
      PostToFaye.request_update('quadrant',[quadrant.id])
      PostToFaye.remove_model_delayed(attacked_ship.id,'ship')
    else
      PostToFaye.request_update('ship',[attacked_ship.id])
    end
    return outcome
  end



  def attacked(actor,damage)
    #update damage
    self.class.where{id == my{self.id}}.update_all("damage = damage + #{damage.to_i}" )
    self.reload
    #check if base is destroyed
    if self.damage >= self.the_sky_map_ship_type.health
      #destroy base
      self.destroy
    end
    true
  end
end
