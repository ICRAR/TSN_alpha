class CreateTheSkyMapBaseUpgradeTypes < ActiveRecord::Migration
  def change
    create_table :the_sky_map_base_upgrade_types do |t|
      t.string :name
      t.text :desc
      t.integer :cost
      t.integer :duration
      t.integer :income
      t.integer :score
      t.integer :parent_id
      t.health :health, default: 0
      t.health :attack, default: 0


      t.timestamps
    end
    add_index :the_sky_map_base_upgrade_types, [:parent_id],
              :name => "parent_id"

    create_table :the_sky_map_base_upgrade_type_hierarchies, :id => false do |t|
      t.integer  :ancestor_id, :null => false   # ID of the parent/grandparent/great-grandparent/... tag
      t.integer  :descendant_id, :null => false # ID of the target tag
      t.integer  :generations, :null => false   # Number of generations between the ancestor and the descendant. Parent/child = 1, for example.
    end

    # For "all progeny of…" and leaf selects:
    add_index :the_sky_map_base_upgrade_type_hierarchies, [:ancestor_id, :descendant_id, :generations],
              :unique => true, :name => "anc_desc_udx"

    # For "all ancestors of…" selects,
    add_index :the_sky_map_base_upgrade_type_hierarchies, [:descendant_id],
              :name => "desc_idx"
  end
end
