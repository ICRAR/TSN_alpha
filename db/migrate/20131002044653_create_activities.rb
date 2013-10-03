class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :profile
      t.integer :num_profiles
      t.string :action
      t.belongs_to :trackable
      t.string :trackable_type

      t.timestamps
    end
    add_index :activities, :profile_id
    add_index :activities, :trackable_id
  end
end
