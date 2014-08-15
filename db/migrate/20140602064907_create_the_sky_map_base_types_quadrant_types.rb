class CreateTheSkyMapBaseTypesQuadrantTypes < ActiveRecord::Migration
  def change
    create_table :the_sky_map_base_types_quadrant_types do |t|
      t.references :the_sky_map_quadrant_type
      t.references :the_sky_map_base_upgrade_type
    end

    add_index :the_sky_map_base_types_quadrant_types, [:the_sky_map_quadrant_type_id,:the_sky_map_base_upgrade_type_id],
              :name => "join_index"
  end
end
