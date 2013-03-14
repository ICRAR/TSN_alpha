class BoincStatsItem < ActiveRecord::Base
  extend GraphiteUrlModule
  include GraphiteUrlModule

  attr_accessible :boinc_id, :credit, :RAC, :rank
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  def render_credit_graph_url
    simple_graph("stats.gauges.TSN_dev.boinc.users.#{boinc_id}.credit")
  end
  def self.render_credit_total_url
    simple_graph("stats.gauges.TSN_dev.boinc.stat.total_credit")
  end
  def self.render_total_users_url
    simple_graph("stats.gauges.TSN_dev.boinc.stat.active_users")
  end
end
