class AddSaveValueToBoincStatsItem < ActiveRecord::Migration
  def change
    add_column :boinc_stats_items, :save_value, :integer
  end
end
