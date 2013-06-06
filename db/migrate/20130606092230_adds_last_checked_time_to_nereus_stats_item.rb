class AddsLastCheckedTimeToNereusStatsItem < ActiveRecord::Migration
  def change
    add_column :nereus_stats_items, :last_checked_time, :datetime, :default => nil
    NereusStatsItem.reset_column_information
    NereusStatsItem.all.each do |n|
      n.update_attribute :last_checked_time, nil
    end
  end
end
