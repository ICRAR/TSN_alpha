class AddPowerUserToGeneralStatsItem < ActiveRecord::Migration
  def change
    add_column :general_stats_items, :power_user, :boolean, :null => false, :default => false
  end
end
