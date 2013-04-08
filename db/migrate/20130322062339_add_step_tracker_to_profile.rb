class AddStepTrackerToProfile < ActiveRecord::Migration
  def up
    change_table :profiles do |t|
      t.integer :new_profile_step, :null => false, :default => 0
    end
    Profile.reset_column_information
    Profile.update_all ["new_profile_step = ?", 2]
  end

  def down
    remove_column :profiles, :new_profile_step
  end
end
