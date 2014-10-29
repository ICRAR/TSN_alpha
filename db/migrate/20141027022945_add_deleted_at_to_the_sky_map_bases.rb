class AddDeletedAtToTheSkyMapBases < ActiveRecord::Migration
  def change
    add_column :the_sky_map_bases, :deleted_at, :datetime
    add_index :the_sky_map_bases, :deleted_at
  end
end
