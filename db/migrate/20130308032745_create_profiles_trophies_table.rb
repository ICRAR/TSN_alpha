class CreateProfilesTrophiesTable < ActiveRecord::Migration
  def self.up
    create_table :profiles_trophies, :id => false do |t|
      t.references :trophy
      t.references :profile
    end
    add_index :profiles_trophies, [:trophy_id, :profile_id]
    add_index :profiles_trophies, [:profile_id, :trophy_id]
  end

  def self.down
    drop_table :profiles_trophies
  end
end
