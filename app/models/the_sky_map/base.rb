class TheSkyMap::Base < ActiveRecord::Base
  attr_accessible :name
  belongs_to :the_sky_map_base_upgrade_type,
                          :class_name => 'TheSkyMap::BaseUpgradeType',
                          foreign_key: "the_sky_map_base_upgrade_type_id"

  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  def the_sky_map_player_id
    the_sky_map_quadrant.owner_id
  end

  def self.for_show(player,base_id)
    self.fog_of_war(player).find(base_id)
  end

  def self.for_index(player)
    TheSkyMap::Base.fog_of_war(player).all
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
  def actions_list
    ['upgrade','build_ship']
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


end
