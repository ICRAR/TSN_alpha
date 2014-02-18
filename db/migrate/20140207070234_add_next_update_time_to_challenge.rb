class AddNextUpdateTimeToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :next_update_time, :datetime
  end
end
