class AddThumbnailPathToTheSkyMapQuadrantType < ActiveRecord::Migration
  def change
    add_column :the_sky_map_quadrant_types, :thumbnail_path, :string
  end
end
