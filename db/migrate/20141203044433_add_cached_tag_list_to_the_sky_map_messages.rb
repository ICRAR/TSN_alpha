class AddCachedTagListToTheSkyMapMessages < ActiveRecord::Migration
  def change
    add_column :the_sky_map_messages, :cached_tag_list, :string
  end
end
