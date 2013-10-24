class AddSlugToSciencePortal < ActiveRecord::Migration
  def change
    add_column :science_portals, :slug, :string
    add_index :science_portals, :slug, :unique => true
  end
end
