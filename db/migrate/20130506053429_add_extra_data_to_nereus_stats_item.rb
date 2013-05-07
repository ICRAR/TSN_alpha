class AddExtraDataToNereusStatsItem < ActiveRecord::Migration
  def change
    add_column :nereus_stats_items, :network_limit, :integer, :default => 0
    add_column :nereus_stats_items, :monthly_network_usage, :integer, :default => 0, :limit => 8 #creates a big int
    add_column :nereus_stats_items, :paused, :integer, :default => 0
    add_column :nereus_stats_items, :active, :integer
    add_column :nereus_stats_items, :online_today, :integer
    add_column :nereus_stats_items, :online_now, :integer
    add_column :nereus_stats_items, :mips_now, :integer
    add_column :nereus_stats_items, :mips_today, :integer
  end
end
