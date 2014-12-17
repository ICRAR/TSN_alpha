class TheSkyMap::Base < ActiveRecord::Base
  extend Memoist
  acts_as_paranoid
  attr_accessible :name, :damage
  belongs_to :the_sky_map_base_upgrade_type,
                          :class_name => 'TheSkyMap::BaseUpgradeType',
                          foreign_key: "the_sky_map_base_upgrade_type_id"

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  def display_name
    "#{the_sky_map_base_upgrade_type.name} (#{id})"
  end
  def the_sky_map_player_id
    respond_to?(:the_sky_map_player_id_sql) ? the_sky_map_player_id_sql : the_sky_map_quadrant.owner_id
  end
  def remaining_health
    self.the_sky_map_base_upgrade_type.health - self.damage
  end
  def self.for_show(player,base_id)
    self.fog_of_war(player).find(base_id)
  end

  def self.for_index(player)
    TheSkyMap::Base.fog_of_war(player).scoped.includes(:the_sky_map_base_upgrade_type).select("`#{self.table_name}`.*").includes(the_sky_map_quadrant: :owner)
  end
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_quadrant_id", primary_key: "the_sky_map_quadrant_id"
  def self.fog_of_war(player)
    if player.options['fog_of_war_on']
      TheSkyMap::Base.joins{the_sky_map_players_quadrants}.
          where{the_sky_map_players_quadrants.the_sky_map_player_id == player.id}.
          where{the_sky_map_players_quadrants.explored == true}
    else
      TheSkyMap::Base.joins{the_sky_map_quadrant}.where{the_sky_map_quadrant.game_map_id == my{player.game_map_id}}
    end
  end

  def self.first_base(quadrant, type = nil)
    new_base = self.new
    new_base.name = "New Base Name"
    new_base.the_sky_map_quadrant = quadrant

    if type.nil?
      new_base.the_sky_map_base_upgrade_type = TheSkyMap::BaseUpgradeType.first_base
    else
      new_base.the_sky_map_base_upgrade_type = type
    end
    new_base.save
    quadrant.update_totals
    new_base
  end

  def allowed_upgrades
    quadrant_type_id = self.the_sky_map_quadrant.the_sky_map_quadrant_type_id
    self.the_sky_map_base_upgrade_type.children.joins{the_sky_map_quadrant_types}.
      where{the_sky_map_quadrant_types.id == my{quadrant_type_id}}
  end
  def allowed_ships
    self.the_sky_map_base_upgrade_type.the_sky_map_ship_types
  end

  #check that ships is attackable and then add the action
  def auto_attack(ship)
    self.perform_action(the_sky_map_quadrant.owner,"auto_attack_ship_#{ship.id}")
  end

  #actions
  acts_as_actionable
  def default_actor
    the_sky_map_quadrant.nil? ? nil : the_sky_map_quadrant.owner
  end
  def actions_list
    ['upgrade','build_ship', 'attack_ship','auto_attack_ship']
  end
  def is_upgrading?
    !current_action.nil? && current_action.action == 'upgrade'
  end
  memoize :is_upgrading?
  def upgrade_options(actor)
    return {} if is_upgrading?
    out_hash = {}
    allowed_upgrades.each do |upgrade|
      action_name = "upgrade_to_#{upgrade.id}".to_sym
      out_hash[action_name] = {
          action: 'upgrade',
          name: "Upgrades this base to #{upgrade.name}",
          cost: upgrade.cost,
          duration: upgrade.duration,
          options: {upgrade_id: upgrade.id},
          allowed: true,
          icon: 'glyphicon-eject'
      }

    end
    out_hash
  end
  def perform_upgrade(options)
    old_name  = self.display_name
    upgrade = self.allowed_upgrades.find(options[:upgrade_id])
    return false if upgrade.nil?
    self.the_sky_map_base_upgrade_type = upgrade
    self.save
    the_sky_map_quadrant.update_totals
    PostToFaye.request_update('base',[self.id],self.the_sky_map_quadrant.game_map_id)
    the_sky_map_quadrant.owner.send_msg("Your #{old_name} has upgraded to a #{upgrade.name}",quadrant: the_sky_map_quadrant, tags: ['base','upgrade'])
    true
  end

  def build_ship_options(actor)
    return {} if is_upgrading?
    out_hash = {}
    allowed_ships.each do |ship|
      action_name = "build_ship_#{ship.id}".to_sym
      out_hash[action_name] = {
          action: 'build_ship',
          name: "Build a new #{ship.name} at this base",
          cost: ship.cost,
          duration: ship.duration,
          options: {ship_type_id: ship.id},
          allowed: true,
          icon: 'glyphicon-plane'
      }
    end
    out_hash
  end
  def perform_build_ship(options)
    ship_type = self.allowed_ships.find(options[:ship_type_id])
    return false if ship_type.nil?
    quadrant = the_sky_map_quadrant
    player = quadrant.owner
    new_ship = ship_type.build_new(quadrant,player)
    return false if new_ship.nil?

    #explore surrounding quadrants as needed
    explored_quadrants =  player.explore_quadrant(quadrant,ship_type.sensor_range)

    #force update to open quadrants
    player_id = player.id
    update_quadrants = explored_quadrants - [quadrant.id]
    PostToFaye.request_update_player_only('quadrant',update_quadrants,[player_id],self.the_sky_map_quadrant.game_map_id)
    PostToFaye.request_update_player_only('mini_quadrant',update_quadrants,[player_id],self.the_sky_map_quadrant.game_map_id)
    PostToFaye.request_update('quadrant',[quadrant.id],self.the_sky_map_quadrant.game_map_id)

    the_sky_map_quadrant.owner.send_msg("Your #{self.display_name} has finished building a new #{ship_type.name} ship.",quadrant: the_sky_map_quadrant, tags: ['base','build ship', 'ship'])
    return true
  end

  def attack_ship_options(actor)
    quadrant = the_sky_map_quadrant

    if quadrant.has_attackable_ships?(quadrant.owner)
      available_ships = {}
      quadrant.attackable_ships(quadrant.owner).each do |attacked_ship|
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
      the_sky_map_player.send_msg("Your #{self.display_name} missed an attack on a #{attacked_ship.name}",quadrant: quadrant, tags: ['base','attack'])
      return true
    end
    #attack the ship
    outcome = self.attack(attacked_ship)
    #send messages
    if outcome[:defender_killed] == true
      msg_to_attacker = "Your #{self.display_name} attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage and destroyed the ship."
      msg_to_defender = "Your #{attacked_ship.name} was attacked by the #{self.display_name} for #{outcome[:attack_damage]} damage and was destroyed."
    elsif outcome[:attacker_killed] == true
      msg_to_attacker = "Your #{self.display_name} attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage however the ship retaliated for #{outcome[:defend_damage]} damage destroying your base."
      msg_to_defender = "Your #{attacked_ship.name} was attacked by the #{self.display_name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage destroying the base."
    else
      msg_to_attacker = "Your #{self.display_name} attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage and the ship retaliated for #{outcome[:defend_damage]} damage."
      msg_to_defender = "Your #{attacked_ship.name} was attacked by the #{self.display_name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage."
    end
    the_sky_map_player.send_msg(msg_to_attacker,quadrant: quadrant, tags: ['base','attack'])
    attacked_ship.the_sky_map_player.send_msg(msg_to_defender,quadrant: quadrant, tags: ['ship','attack'])
    return outcome[:action_outcome]
    end
  def auto_attack_ship_options(actor)
    quadrant = the_sky_map_quadrant

    if quadrant.has_attackable_ships?(quadrant.owner)
      available_ships = {}
      quadrant.attackable_ships(quadrant.owner).each do |attacked_ship|
        action_name = "auto_attack_ship_#{attacked_ship.id}".to_sym
        available_ships[action_name] = {
            action: 'auto_attack_ship',
            name: "Attack the Ship: #{attacked_ship.id}",
            cost: 100,
            duration: 60,
            options: {ship_id: attacked_ship.id},
            allowed: true,
            icon: 'glyphicon-screenshot',
            display: false
        }
      end
      available_ships
    else
      {}
    end
  end
  def perform_auto_attack_ship(opts)
    attacked_ship = TheSkyMap::Ship.find(opts[:ship_id])
    quadrant = the_sky_map_quadrant

    #check if attacked ship is in the your quadrant
    unless quadrant == attacked_ship.the_sky_map_quadrant
      the_sky_map_player.send_msg("Your Base missed an auto attack on a #{attacked_ship.name}",quadrant: quadrant, tags: ['base','attack'])
      return false
    end

    #attack the ship
    outcome = self.attack(attacked_ship)
    #send messages
    if outcome[:defender_killed] == true
      msg_to_attacker = "Your #{self.display_name} auto attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage and destroyed the ship."
      msg_to_defender = "Your #{attacked_ship.name} was auto attacked by the #{self.display_name} for #{outcome[:attack_damage]} damage and was destroyed."
    elsif outcome[:attacker_killed] == true
      msg_to_attacker = "Your #{self.display_name} auto attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage however the ship retaliated for #{outcome[:defend_damage]} damage destroying your base."
      msg_to_defender = "Your #{attacked_ship.name} was auto attacked by the #{self.display_name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage destroying the base."
    else
      msg_to_attacker = "Your #{self.display_name} auto attacked the #{attacked_ship.name} for #{outcome[:attack_damage]} damage and the ship retaliated for #{outcome[:defend_damage]} damage."
      msg_to_defender = "Your #{attacked_ship.name} was auto attacked by the #{self.display_name} for #{outcome[:attack_damage]} damage and then retaliated for #{outcome[:defend_damage]} damage."
    end
    the_sky_map_player.send_msg(msg_to_attacker,quadrant: quadrant, tags: ['base','attack'])
    attacked_ship.the_sky_map_player.send_msg(msg_to_defender,quadrant: quadrant, tags: ['ship','attack'])
    return outcome[:action_outcome]
  end



  def attack_value
    self.the_sky_map_base_upgrade_type.attack
  end
  def health_value
    self.the_sky_map_base_upgrade_type.health
  end
  def model_name
    'base'
  end
  def the_sky_map_player
    self.the_sky_map_quadrant.owner
  end

  acts_as_combatant

end
