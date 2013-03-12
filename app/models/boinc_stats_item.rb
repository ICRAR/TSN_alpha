class BoincStatsItem < ActiveRecord::Base
  attr_accessible :boinc_id, :credit, :RAC, :rank

  belongs_to :general_stats_item

end
