class TheSkyMap::QuadrantType < ActiveRecord::Base
  #generation chance is a scaled varible that determines the chance that the this type will appear on the map when
  # creating a new quadrant
  attr_accessible :desc, :name, :unexplored_name, :num_of_bases, :score, :feature_type, :generation_chance,
                  :unexplored_symbol, :explored_symbol, :suitable_for_home, :thumbnail_path,
                  :gen_x_min, :gen_x_max, :gen_y_min, :gen_y_max, as: [:admin, :default]

  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_type_id"
  validates_uniqueness_of :name
  validates_presence_of :desc, :name, :unexplored_name, :num_of_bases, :score, :feature_type, :generation_chance,
                        :unexplored_symbol, :explored_symbol, :gen_x_min, :gen_x_max, :gen_y_min, :gen_y_max
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
  def find_galaxy_id
    return nil if self.gen_x_max == 0
    #uses the gen_x/y_min/max values to find a suitable galaxy for a new quadrant
    #gen_x represents the size of the x_axis in the galaxy image in pixels
    #gen_y is the id of the galaxy
    already_picked_galaxies = the_sky_map_quadrants.pluck(:galaxy_id)
    galaxies = Galaxy.where{(dimension_x >= my{self.gen_x_min}) & (dimension_x < my{self.gen_x_max})}.
      where{(ra_cent >= my{self.gen_y_min}) & (ra_cent < my{self.gen_y_max})}.
      where{galaxy_id.not_in already_picked_galaxies}
    possible_ids = galaxies.pluck(:galaxy_id)
    id = possible_ids.sample
  end
end
