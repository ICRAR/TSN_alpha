class TheSkyMap::Base < ActiveRecord::Base
  attr_accessible :name, :damage
  belongs_to :the_sky_map_base_upgrade_type,
                          :class_name => 'TheSkyMap::BaseUpgradeType',
                          foreign_key: "the_sky_map_base_upgrade_type_id"

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  def the_sky_map_player_id
    the_sky_map_quadrant.owner_id
  end
  def remaining_health
    self.the_sky_map_base_upgrade_type.health - self.damage
  end
  def self.for_show(player,base_id)
    self.fog_of_war(player).find(base_id)
  end

  def self.for_index(player)
    TheSkyMap::Base.fog_of_war(player).scoped
  end
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_quadrant_id", primary_key: "the_sky_map_quadrant_id"
  def self.fog_of_war(player)
    if player.options['fog_of_war_on']
      TheSkyMap::Base.joins{the_sky_map_players_quadrants}.
          where{the_sky_map_players_quadrants.the_sky_map_player_id == player.id}.
          where{the_sky_map_players_quadrants.explored == true}
    else
      TheSkyMap::Base
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

  #actions
  acts_as_actionable
  def default_actor
    the_sky_map_quadrant.owner
  end
  def actions_list
    ['upgrade','build_ship', 'attack_ship']
  end
  def upgrade_options(actor)
    return {} if !current_action.nil? && current_action.action == 'upgrade'
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
    upgrade = self.allowed_upgrades.find(options[:upgrade_id])
    return false if upgrade.nil?
    self.the_sky_map_base_upgrade_type = upgrade
    self.save
    the_sky_map_quadrant.update_totals
    PostToFaye.request_update('base',[self.id])
    true
  end

  def build_ship_options(actor)
    return {} if !current_action.nil? && current_action.action == 'upgrade'
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
    new_ship = ship_type.build_new(the_sky_map_quadrant,the_sky_map_quadrant.owner)
    return false if new_ship.nil?
    PostToFaye.request_update('quadrant',[the_sky_map_quadrant.id])
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
    return true unless quadrant == attacked_ship.the_sky_map_quadrant

    #attack the base
    outcome = attacked_ship.attacked(quadrant.owner,the_sky_map_base_upgrade_type.attack)
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
    if self.damage >= self.the_sky_map_base_upgrade_type.health
      #destroy base
      self.destroy
    end
    true
  end

end
