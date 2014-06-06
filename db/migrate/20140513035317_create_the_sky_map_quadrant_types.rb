class CreateTheSkyMapQuadrantTypes < ActiveRecord::Migration
  def change
    create_table :the_sky_map_quadrant_types do |t|
      t.text :desc
      t.string :name
      t.string :unexplored_name
      t.string :feature_type
      t.string :unexplored_color
      t.string :explored_color
      t.string :feature_type
      t.integer :num_of_bases
      t.integer :score
      t.integer :generation_chance
      t.boolean :suitable_for_home, null: false, default: false
      t.string :unexplored_symbol
      t.string :explored_symbol

      t.timestamps
    end
  end
end
