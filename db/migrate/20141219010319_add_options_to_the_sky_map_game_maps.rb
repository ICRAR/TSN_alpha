class AddOptionsToTheSkyMapGameMaps < ActiveRecord::Migration
  def change
    add_column :the_sky_map_game_maps, :options, :text
    add_column :the_sky_map_game_maps, :state, :integer
    add_column :the_sky_map_game_maps, :finished_at, :datetime
    add_column :the_sky_map_game_maps, :running_at, :datetime
    add_column :manager_id, :running_at, :integer


  end
end
