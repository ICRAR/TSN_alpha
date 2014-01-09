class AddChallengeToBoincStatsItem < ActiveRecord::Migration
  def change
    add_column :boinc_stats_items, :challenge, :integer
  end
end
