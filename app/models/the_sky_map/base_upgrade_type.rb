class TheSkyMap::BaseUpgradeType < ActiveRecord::Base
  attr_accessible :cost, :desc, :duration, :income, :score, :name, :attack, :health, as: [:admin, :default]

  has_and_belongs_to_many :the_sky_map_quadrant_types,
                          :class_name => 'TheSkyMap::QuadrantType',
                          :join_table => 'the_sky_map_base_types_quadrant_types',
                          association_foreign_key: "the_sky_map_quadrant_type_id",
                          foreign_key: "the_sky_map_base_upgrade_type_id"

  has_many :the_sky_map_bases,
                          :class_name => 'TheSkyMap::Base',
                          foreign_key: "the_sky_map_base_upgrade_type_id"
  has_and_belongs_to_many :the_sky_map_ship_types,
                          :class_name => 'TheSkyMap::ShipType',
                          :join_table => 'the_sky_map_base_types_ship_types',
                          association_foreign_key: "the_sky_map_ship_type_id",
                          foreign_key: "the_sky_map_base_upgrade_type_id"

  acts_as_tree #for upgrade_path

  def self.first_base
    self.where{name == "Base Base"}.first
  end
end
