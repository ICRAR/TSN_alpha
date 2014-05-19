class CreateTheSkyMapShipTypes < ActiveRecord::Migration
  def change
    create_table :the_sky_map_ship_types do |t|
      t.string :name
      t.text :desc
      t.integer :speed
      t.integer :health
      t.integer :attack

      t.timestamps
    end
  end
end
