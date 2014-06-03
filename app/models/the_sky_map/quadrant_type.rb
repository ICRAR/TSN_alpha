class TheSkyMap::QuadrantType < ActiveRecord::Base
  #generation chance is a scaled varible that determines the chance that the this type will appear on the map when
  # creating a new quadrant
  attr_accessible :desc, :name, :unexplored_name, :num_of_bases, :score, :feature_type, :generation_chance,
                  :unexplored_color, :explored_color, as: [:admin]

  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_type_id"

  validates_presence_of :desc, :name, :unexplored_name, :num_of_bases, :score, :feature_type, :generation_chance,
                        :unexplored_color, :explored_color
  has_and_belongs_to_many :the_sky_map_base_upgrade_types,
                          :class_name => 'TheSkyMap::BaseUpgradeType',
                          :join_table => 'the_sky_map_base_types_quadrant_types',
                          association_foreign_key: "the_sky_map_base_upgrade_type_id",
                          foreign_key: "the_sky_map_quadrant_type_id"
  def self.generation_chance_table
    gt = {
        min: 0,
        max: 0,
        chances: {}
    }
    all_types = self.all
    all_types.each do |type|
      gt[:min] = 1 if gt[:min] == 0 && type.generation_chance > 0
      old_max = gt[:max] + 1
      new_max = gt[:max] + type.generation_chance
      (old_max..new_max).each do |i|
        gt[:chances][i] = type.id
      end
      gt[:max] = gt[:max] + type.generation_chance

    end
    gt
  end
  def self.pick_random_id(chance_table)
    rnum = rand(chance_table[:min]..chance_table[:max])
    chance_table[:chances][rnum]
  end
end
