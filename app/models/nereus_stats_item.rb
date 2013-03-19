class NereusStatsItem < ActiveRecord::Base
  extend GraphiteUrlModule
  include GraphiteUrlModule

  attr_accessible :credit, :daily_credit, :nereus_id, :rank
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item


  def render_credit_graph_url
    simple_graph("stats.gauges.TSN_dev.nereus.users.#{nereus_id}.credit")
  end
  def self.render_credit_total_url
    simple_graph("stats.gauges.TSN_dev.nereus.stats.total_credit")
  end
  def self.render_total_users_url
    simple_graph("stats.gauges.TSN_dev.nereus.stats.users_with_daily_credit")
  end

  def self.render_tflops_url
    graph_url('scale(stats.gauges.TSN_dev.nereus.stats.total_daily_credit%2C0.000125)',400,250,'-7days','Approx_Current_Tflops')
  end

end
