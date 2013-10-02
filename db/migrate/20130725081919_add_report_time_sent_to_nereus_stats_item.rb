class AddReportTimeSentToNereusStatsItem < ActiveRecord::Migration
  def change
    add_column :nereus_stats_items, :report_time_sent, :timestamp
  end
end
