class CreateTheSkyMapGameMaps < ActiveRecord::Migration
  def change
    create_table :the_sky_map_game_maps do |t|
      t.integer :x_min
      t.integer :x_max
      t.integer :y_min
      t.integer :y_max
      t.timestamps
    end
    add_column :the_sky_map_players, :game_map_id, :integer
    add_index :the_sky_map_players, :game_map_id

    remove_index :the_sky_map_quadrants, :name => "location_index"
    rename_column :the_sky_map_quadrants, :z, :game_map_id
    add_index :the_sky_map_quadrants, ["game_map_id","y","x"], unique: true, name: "location_index"
  end
end
