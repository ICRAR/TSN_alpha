class AddCurrentToTheSkyMapPlayer < ActiveRecord::Migration
  def change
    add_column :the_sky_map_players, :current, :boolean
    remove_index :the_sky_map_players, :name => "profile_index"
    add_index :the_sky_map_players, ["profile_id", "current"], name: "profile_index"
  end
end
