class CreateTheSkyMapBases < ActiveRecord::Migration
  def change
    create_table :the_sky_map_bases do |t|
      t.string :name
      t.references :the_sky_map_quadrant
      t.references :the_sky_map_base_upgrade_type


      t.timestamps
    end
    add_index :the_sky_map_bases, [:the_sky_map_quadrant_id]

  end
end
