class CreateTheSkyMapPlayer < ActiveRecord::Migration
  def change
    create_table :the_sky_map_players do |t|
      t.integer :score, default: 0
      t.integer :rank, default: 0
      t.integer :total_points, default: 0
      t.integer :spent_points, default: 0
      t.integer :total_points_special, default: 0
      t.integer :spent_points_special, default: 0
      t.integer :total_income, default: 0
      t.integer :total_income_special, default: 0
      t.integer :total_score, default: 0
      t.double :total_points_float
      t.double :total_points_special_float, default: 0
      t.text :options
      t.belongs_to :profile
      t.belongs_to :home

      t.timestamps
    end
    add_index :the_sky_map_players, ["profile_id"], name: "profile_index"
    add_index :the_sky_map_players, ["score"], name: "score_index"
    add_index :the_sky_map_players, ["rank"], name: "rank_index"
  end

end
