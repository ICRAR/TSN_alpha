class AddReportCountToBoincStatsItem < ActiveRecord::Migration
  def change
    add_column :boinc_stats_items, :report_count, :integer
  end
end
