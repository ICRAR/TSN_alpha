class AddHealValueToTheSkyMapShipType < ActiveRecord::Migration
  def change
    add_column :the_sky_map_ship_types, :heal, :integer
  end
end
