class AddGalaxyIdToTheSkyMapQuadrant < ActiveRecord::Migration
  def change
    add_column :the_sky_map_quadrants, :galaxy_id, :integer
    add_column :the_sky_map_quadrants, :thumbnail_link, :string
  end
end
