class CreateTheSkyMapShipTypes < ActiveRecord::Migration
  def change
    create_table :the_sky_map_ship_types do |t|
      t.string :name
      t.text :desc
      t.integer :speed
      t.integer :health
      t.integer :attack
      t.integer :cost
      t.integer :duration
      t.boolean :can_build_bases, null: false, default: false

      t.timestamps
    end
  end
end
