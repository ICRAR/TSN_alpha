class AddGalaxyTypeToQuadrantTypes < ActiveRecord::Migration
  def change
    add_column :the_sky_map_quadrant_types, :gen_x_min, :integer
    add_column :the_sky_map_quadrant_types, :gen_x_max, :integer
    add_column :the_sky_map_quadrant_types, :gen_y_min, :integer
    add_column :the_sky_map_quadrant_types, :gen_y_max, :integer
    remove_column :the_sky_map_quadrant_types, :unexplored_color
    remove_column :the_sky_map_quadrant_types, :explored_color
  end
end
