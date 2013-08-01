class CreateMembersSciencePortals < ActiveRecord::Migration
  create_table :members_science_portals, :id => false do |t|
    t.references :member, :science_portal
  end

  add_index :members_science_portals, [:member_id, :science_portal_id]
end
