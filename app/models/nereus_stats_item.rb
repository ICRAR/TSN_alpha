class NereusStatsItem < ActiveRecord::Base

  attr_accessible :credit, :daily_credit, :nereus_id, :rank
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item


end
