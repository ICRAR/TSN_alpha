class BoincStatsItem < ActiveRecord::Base
  attr_accessible :boinc_id, :credit, :RAC, :rank

  belongs_to :general_stats_item

  def render_credit_graph_url
    return APP_CONFIG['graphite_url'] + "render?from=-12hours&until=now&width=400&height=250&target=stats.gauges.TSN_dev.boinc.#{boinc_id}.credit&title=boinc%20credit"
  end
end
