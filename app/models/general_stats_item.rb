class GeneralStatsItem < ActiveRecord::Base
  attr_accessible :rank, :recent_avg_credit, :total_credit
  has_one :boinc_stats_item
  belongs_to :profile


end
