class CreateTheSkyMapShips < ActiveRecord::Migration
  def change
    create_table :the_sky_map_ships do |t|
      t.integer :damage, default: 0
      t.references :the_sky_map_ship_type
      t.references :the_sky_map_player
      t.references :the_sky_map_quadrant

      t.timestamps
    end
  end
end
