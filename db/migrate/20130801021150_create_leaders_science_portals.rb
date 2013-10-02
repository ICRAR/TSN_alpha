class CreateLeadersSciencePortals < ActiveRecord::Migration
  create_table :leaders_science_portals, :id => false do |t|
    t.references :leader, :science_portal
  end

  add_index :leaders_science_portals, [:leader_id, :science_portal_id]
end
