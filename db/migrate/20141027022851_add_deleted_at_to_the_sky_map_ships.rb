class AddDeletedAtToTheSkyMapShips < ActiveRecord::Migration
  def change
    add_column :the_sky_map_ships, :deleted_at, :datetime
    add_index :the_sky_map_ships, :deleted_at
  end
end
