class TheSkyMap::ShipType < ActiveRecord::Base
  attr_accessible :attack, :desc, :health, :name, :speed, :cost, :duration, :can_build_bases, :sensor_range, :heal, as: [:admin, :default]
  validates_presence_of :attack, :desc, :health, :name, :cost, :duration, :speed, :sensor_range, :heal
  validates_uniqueness_of :name

  has_many :the_sky_map_ships,
           :class_name => 'TheSkyMap::Ship',
           foreign_key: "the_sky_map_ship_type_id"
  has_and_belongs_to_many :the_sky_map_base_upgrade_types,
                          :class_name => 'TheSkyMap::BaseUpgradeType',
                          :join_table => 'the_sky_map_base_types_ship_types',
                          association_foreign_key: "the_sky_map_base_upgrade_type_id",
                          foreign_key: "the_sky_map_ship_type_id"

  def build_new(quadrant,player)
    new_ship = self.the_sky_map_ships.build()
    new_ship.the_sky_map_quadrant =  quadrant
    new_ship.the_sky_map_player =  player
    new_ship.save
    new_ship
  end
end
