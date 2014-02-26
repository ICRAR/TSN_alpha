class StatsAlliancesJob
  include Delayed::ScheduledJob
  run_every 1.hour
  def perform
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update credit alliance member items') {
        AllianceMembers.current.joins_gsi.update_all('alliance_members.leave_credit = general_stats_items.total_credit')
        #fix any possible broken alliance members negative credit is not possible
        AllianceMembers.where{leave_credit < start_credit}.update_all("leave_credit = start_credit")

        Alliance.update_all_credits
        Alliance.update_all_rac_current_members
        Alliance.update_ranks

        #update stats
        Alliance.find_each do |alliance|
          statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.daily_credit",alliance.RAC)
          statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.current_members",alliance.current_members)
          statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.total_credit",alliance.credit)
          statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.rank", alliance.ranking)
        end
      }
      statsd_batch.flush
    end
  end
end