class CreateTheSkyMapQuadrant < ActiveRecord::Migration
  def change
    create_table :the_sky_map_quadrants do |t|
      t.integer :x
      t.integer :y
      t.integer :z

      t.integer :total_score
      t.integer :total_income

      t.references :the_sky_map_quadrant_type
      t.references :owner

      t.timestamps
    end
    add_index :the_sky_map_quadrants, ["z","y","x"], unique: true, name: "location_index"
    add_index :the_sky_map_quadrants, ["owner_id"], name: "owner_index"
  end
end
