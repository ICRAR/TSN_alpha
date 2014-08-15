class CreateTheSkyMapPlayersQuadrants < ActiveRecord::Migration
  def change
    create_table :the_sky_map_players_quadrants do |t|
      t.references :the_sky_map_quadrant
      t.references :the_sky_map_player

      t.integer :explored, default: 0

      t.timestamps
    end

    add_index :the_sky_map_players_quadrants, [:the_sky_map_quadrant_id, :the_sky_map_player_id], unique: true, name: 'player_id_quadrant_id'
  end
end
