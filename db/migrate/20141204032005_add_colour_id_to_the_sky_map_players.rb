class AddColourIdToTheSkyMapPlayers < ActiveRecord::Migration
  def change
    add_column :the_sky_map_players, :colour_id, :integer
  end
end
