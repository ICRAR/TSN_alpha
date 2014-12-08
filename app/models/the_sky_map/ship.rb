class TheSkyMap::Ship < TheSkyMap::BaseModel
  extend Memoist
  acts_as_paranoid
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
    TheSkyMap::Ship.fog_of_war(player).scoped.includes(:the_sky_map_ship_type, :the_sky_map_player)
  end
  def self.fog_of_war(player)
    if player.options['fog_of_war_on']
      TheSkyMap::Ship.joins{the_sky_map_players_quadrants}.
          where{the_sky_map_players_quadrants.the_sky_map_player_id == player.id}.
          where{the_sky_map_players_quadrants.explored == true}
    else
      TheSkyMap::Ship.joins{the_sky_map_quadrant}.where{the_sky_map_quadrant.game_map_id == my{player.game_map_id}}
    end
  end
  def name
    "#{self.the_sky_map_ship_type.name}:#{self.id}"
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
    ['move', 'capture', 'build_base', 'steal', 'attack_base', 'attack_ship','heal_ship','heal_base']
  end
  def moving?
    !current_action.nil? && current_action.action == 'move'
  end
  memoize :moving?
  def build_base_options(actor)
    return {} if moving?
    if the_sky_map_ship_type.can_build_bases?
      quadrant = the_sky_map_quadrant
      bases_allowed = quadrant.bases_allowed(actor)
      if bases_allowed.nil?
        {}
      else
        available_builds = {}
        bases_allowed.each do |base|
          action_name = "build_base_#{base.id}_at_#{quadrant.x}_#{quadrant.y}_map#{quadrant.game_map_id}".to_sym
          available_builds[action_name] = {
                action: 'build_base',
                name: "Build a new '#{base.name}' base on (#{quadrant.x}, #{quadrant.y})",
                cost: base.cost,
                duration: base.duration,
                options: {base_upgrade_type_id: base.id,x: quadrant.x, y: quadrant.y},
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
    PostToFaye.request_update('quadrant',[quadrant.id],self.the_sky_map_quadrant.game_map_id)
    the_sky_map_player.send_msg("You #{new_base.display_name} at (#{quadrant.x},#{quadrant.y}) has been completed", quadrant: quadrant, tags: ['ship','build base'])
    true

  end

  def steal_options(actor)
    #can't queue a steal action if the ship is currenly moving
    return {} if moving?
    quadrant = the_sky_map_quadrant
    if quadrant.is_stealable?(actor)
      action_name = "steal_#{quadrant.x}_#{quadrant.y}_map#{quadrant.game_map_id}".to_sym
      {action_name => {
          action: 'steal',
          name: "Steal the Quadrant (#{quadrant.x}, #{quadrant.y})",
          cost: 500,
          duration: 1200,
          options: {x: quadrant.x, y: quadrant.y},
          allowed: true,
          icon: 'glyphicon-remove-circle'
      }}
    else
      {}
    end
  end
  def perform_steal(opts)
    current_quadrant = self.the_sky_map_quadrant
    quadrant = TheSkyMap::Quadrant.at_pos(opts[:x],opts[:y], current_quadrant.game_map_id)
    #check if ship is still in the correct quadrant
    return false unless current_quadrant.id == quadrant.id
    return false unless quadrant.is_stealable?(the_sky_map_player)
    #capture quadrant
    outcome = quadrant.steal(the_sky_map_player)
    #push changes with faye
    PostToFaye.request_update('quadrant',[quadrant.id],self.the_sky_map_quadrant.game_map_id)
    PostToFaye.request_update('mini_quadrant',[quadrant.id],self.the_sky_map_quadrant.game_map_id)
    if outcome == true
      the_sky_map_player.send_msg("You have successfully stolen the quadrant (#{quadrant.x},#{quadrant.y})",quadrant: quadrant, tags: ['ship','steal quadrant'])
    else
      the_sky_map_player.send_msg("You have failed to steal the quadrant (#{quadrant.x},#{quadrant.y})",quadrant: quadrant, tags: ['ship','steal quadrant'])
    end
    return outcome
  end

  def capture_options(actor)
    return {} if moving?
    quadrant = the_sky_map_quadrant
    if quadrant.owner_id.nil?
      action_name = "capture_#{quadrant.x}_#{quadrant.y}_map#{quadrant.game_map_id}".to_sym
      {action_name => {
          action: 'capture',
          name: "Capture the Quadrant (#{quadrant.x}, #{quadrant.y})",
          cost: 10,
          duration: 60,
          options: {x: quadrant.x, y: quadrant.y},
          allowed: true,
          icon: 'glyphicon-log-in'
      }}
    else
      {}
    end
  end
  def perform_capture(opts)
    current_quadrant = self.the_sky_map_quadrant
    quadrant = TheSkyMap::Quadrant.at_pos(opts[:x],opts[:y], current_quadrant.game_map_id)
    #check if ship is still in the correct quadrant
    return false unless current_quadrant.id == quadrant.id
    #check that the quadrant is still unoccupided
    return false unless quadrant.owner_id.nil?
    #capture quadrant
    outcome = quadrant.capture(the_sky_map_player)
    #push changes with faye
    PostToFaye.request_update('quadrant',[quadrant.id],self.the_sky_map_quadrant.game_map_id)
    PostToFaye.request_update('mini_quadrant',[quadrant.id],self.the_sky_map_quadrant.game_map_id)
    if outcome == true
      the_sky_map_player.send_msg("You have successfully captured the quadrant (#{quadrant.x},#{quadrant.y})",quadrant: quadrant, tags: ['ship','capture quadrant'])
    else
      the_sky_map_player.send_msg("You have failed to capture the quadrant (#{quadrant.x},#{quadrant.y})",quadrant: quadrant, tags: ['ship','capture quadrant'])
    end
    return outcome
  end

  def move_options(actor)
    return {} if moving?
    home = the_sky_map_player.home

    surrounding_quadrants = the_sky_map_quadrant.surrounding_quadrants_move
    if on_hostile_quadrant?
      surrounding_quadrants = surrounding_quadrants.where{(owner_id == nil) | (owner_id == my{the_sky_map_player_id})}
    end
    available_moves = {}
    base_time = 5.minutes
    ships_speed = the_sky_map_ship_type.speed
    move_time = (base_time / ships_speed).to_i
    surrounding_quadrants.each do |quadrant|
      opt = "move_#{quadrant.x}_#{quadrant.y}_map#{quadrant.game_map_id}".to_sym
      distance_to_home = quadrant.distance_to(home.x,home.y)
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
          duration: move_time,
          options: {x: quadrant.x, y: quadrant.y},
          allowed: true,
          icon: "glyphicon-arrow-#{dir}"
      }
    end
    available_moves
  end
  def perform_move(opts)
    current_quadrant = self.the_sky_map_quadrant
    quadrant = TheSkyMap::Quadrant.at_pos(opts[:x],opts[:y], current_quadrant.game_map_id)
    #check if the move is allowed
    #ToDo return false if move is not allowed
    #move
    old_quadrant = self.the_sky_map_quadrant
    self.the_sky_map_quadrant = quadrant
    self.save

    #explore
    explored_quadrants =  self.the_sky_map_player.explore_quadrant(quadrant,self.the_sky_map_ship_type.sensor_range)
    #force update to open quadrants
    full_update_quadrants =  [old_quadrant.id,quadrant.id]
    PostToFaye.request_update('quadrant',full_update_quadrants,self.the_sky_map_quadrant.game_map_id)

    player_id = self.the_sky_map_player_id
    PostToFaye.request_update_player_only('quadrant',(explored_quadrants - full_update_quadrants),[player_id],self.the_sky_map_quadrant.game_map_id)  unless (explored_quadrants - full_update_quadrants) == []
    PostToFaye.request_update_player_only('mini_quadrant',(explored_quadrants + [quadrant.id]),[player_id],self.the_sky_map_quadrant.game_map_id)

    #if there are enemy bases they should automatically initiate an attack on the new ship
    quadrant.auto_attack_incoming_ship self

    #force update to open ship
    PostToFaye.request_update('ship',[self.id],self.the_sky_map_quadrant.game_map_id)
    self.the_sky_map_player.send_msg("Your #{self.name} has arrived at Quadrant (#{quadrant.x},#{quadrant.y})",quadrant: quadrant, tags: ['ship','movement'])
    return true
  end

  def attack_base_options(actor)
    return {} if moving?
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
    unless quadrant == the_sky_map_quadrant
      the_sky_map_player.send_msg("Your #{self.name} missed an attack on a #{base.display_name}",quadrant: quadrant, tags: ['ship','attack'])
      return true
    end

    #attack the base
    outcome = self.attack(base)

    #send messages
    if outcome[:defender_killed] == true
      msg_to_attacker = "Your #{self.name} attacked the #{base.display_name} for #{outcome[:attack_damage]} damage and destroyed the base."
      msg_to_defender = "Your #{base.display_name} was attacked by the #{self.name} for #{outcome[:attack_damage]} damage and was destroyed."
    elsif outcome[:attacker_killed] == true
      msg_to_attacker = "Your #{self.name} attacked the #{base.display_name} for #{outcome[:attack_damage]} damage however the base retaliated for #{outcome[:defend_damage]} damage killing your ship."
      msg_to_defender = "Your #{base.display_name} was attacked by the #{self.name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage killing the ship."
    else
      msg_to_attacker = "Your #{self.name} attacked the #{base.display_name} for #{outcome[:attack_damage]} damage and the base retaliated for #{outcome[:defend_damage]} damage."
      msg_to_defender = "Your #{base.display_name} was attacked by the #{self.name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage."
    end
    the_sky_map_player.send_msg(msg_to_attacker,quadrant: quadrant, tags: ['ship','attack'])
    base.the_sky_map_player.send_msg(msg_to_defender,quadrant: quadrant, tags: ['base','attack'])
    return outcome[:action_outcome]
  end
  def attack_ship_options(actor)
    return {} if moving?
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
    unless quadrant == attacked_ship.the_sky_map_quadrant
      the_sky_map_player.send_msg("Your Ship missed an attack on a #{attacked_ship.name}",quadrant: quadrant, tags: ['ship','attack'])
      return true
    end

    #attack the ship
    outcome = self.attack(attacked_ship)

    #send messages
    if outcome[:defender_killed] == true
      msg_to_attacker = "Your #{self.name} attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage and destroyed the ship."
      msg_to_defender = "Your #{attacked_ship.name} was attacked by the #{self.name} for #{outcome[:attack_damage]} damage and was destroyed."
    elsif outcome[:attacker_killed] == true
      msg_to_attacker = "Your #{self.name} attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage however the ship retaliated for #{outcome[:defend_damage]} damage killing your ship."
      msg_to_defender = "Your #{attacked_ship.name} was attacked by the #{self.name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage killing the ship."
    else
      msg_to_attacker = "Your #{self.name} attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage and the ship retaliated for #{outcome[:defend_damage]} damage."
      msg_to_defender = "Your #{attacked_ship.name} was attacked by the #{self.name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage."
    end
    the_sky_map_player.send_msg(msg_to_attacker,quadrant: quadrant, tags: ['ship','attack'])
    attacked_ship.the_sky_map_player.send_msg(msg_to_defender,quadrant: quadrant, tags: ['ship','attack'])
    return outcome[:action_outcome]
  end


  def heal_ship_options(actor)
    return {} if moving?
    return {} if the_sky_map_ship_type.heal < 1
    quadrant = the_sky_map_quadrant

    if quadrant.has_healable_ships?(the_sky_map_player)
      available_ships = {}
      quadrant.healable_ships(the_sky_map_player).each do |healed_ship|
        action_name = "heal_ship_#{healed_ship.id}".to_sym
        available_ships[action_name] = {
            action: 'heal_ship',
            name: "Heal the Ship: #{healed_ship.id}",
            cost: 100,
            duration: 60,
            options: {ship_id: healed_ship.id},
            allowed: true,
            icon: 'glyphicon-header'
        }
      end
      available_ships
    else
      {}
    end
  end
  def perform_heal_ship(opts)
    healed_ship = TheSkyMap::Ship.find(opts[:ship_id])
    quadrant = the_sky_map_quadrant

    #check if healed ship is in the your quadrant
    #if not return true as you missed and thus forfeit your resources
    return true unless quadrant == healed_ship.the_sky_map_quadrant

    #heal the ship
    outcome = healed_ship.heal(the_sky_map_ship_type.heal)
    the_sky_map_player.send_msg("Your #{healed_ship.name} was healed #{the_sky_map_ship_type.heal} points by the #{name}", quadrant: quadrant, tags: ['ship','heal'])
    return outcome
  end
  def heal_base_options(actor)
    return {} if moving?
    return {} if the_sky_map_ship_type.heal < 1
    quadrant = the_sky_map_quadrant

    if quadrant.has_healable_bases?(the_sky_map_player)
      available_bases = {}
      quadrant.healable_bases(the_sky_map_player).each do |healed_base|
        action_name = "heal_base_#{healed_base.id}".to_sym
        available_bases[action_name] = {
            action: 'heal_base',
            name: "Heal the Base: #{healed_base.id}",
            cost: 100,
            duration: 60,
            options: {base_id: healed_base.id},
            allowed: true,
            icon: 'glyphicon-header'
        }
      end
      available_bases
    else
      {}
    end
  end
  def perform_heal_base(opts)
    healed_base = TheSkyMap::Base.find(opts[:base_id])
    quadrant = the_sky_map_quadrant

    #check if healed ship is in the your quadrant
    #if not return true as you missed and thus forfeit your resources
    return true unless quadrant == healed_base.the_sky_map_quadrant

    #heal the ship
    outcome = healed_base.heal(the_sky_map_ship_type.heal)
    the_sky_map_player.send_msg("Your #{healed_base.display_name} was healed #{the_sky_map_ship_type.heal} points by the #{name}", quadrant: quadrant, tags: ['ship','heal'])
    return outcome
  end



  def attack_value
    self.the_sky_map_ship_type.attack
  end
  def health_value
    self.the_sky_map_ship_type.health
  end
  def model_name
    'ship'
  end

  acts_as_combatant

end
