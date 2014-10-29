class AddSensorRangeToTheSkyMapShipType < ActiveRecord::Migration
  def change
    add_column :the_sky_map_ship_types, :sensor_range, :integer
  end
end
