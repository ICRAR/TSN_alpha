class BoincJob
  include Delayed::ScheduledJob
  run_every 1.hour

  def perform
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('test') {
        total_credit = 0
        total_RAC = 0
        users_with_RAC = 0
        total_users = 0
        boinc_local_items = BoincStatsItem.all
        boinc_hash = Hash[*boinc_local_items.map{|b| [b.boinc_id, b]}.flatten]

        boinc_remote = BoincRemoteUser.all

        BoincStatsItem.transaction do
          boinc_remote.each do |remote|
            local = boinc_hash[remote.id]
            if local.nil?
              local = BoincStatsItem.new
              local.boinc_id = remote.id
              local.report_count = 0
            end
            local.credit = remote.total_credit
            local.RAC = remote.expavg_credit

            total_credit += remote.total_credit
            total_RAC += remote.expavg_credit
            users_with_RAC += (remote.expavg_credit > 10) ? 1 : 0
            total_users += 1
            id = remote.id
            statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.credit",remote.total_credit)
            statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.rac",remote.expavg_credit)

            local.save
          end
        end

        statsd_batch.gauge("boinc.stat.total_credit",total_credit)
        statsd_batch.gauge("boinc.stat.total_rac",total_RAC)
        SiteStat.set("boinc_TFLOPS",(total_RAC*0.000005).round(2))
        statsd_batch.gauge("boinc.stat.total_users",total_users)
        statsd_batch.gauge("boinc.stat.active_users",users_with_RAC)
        statsd_batch.flush

      }
    end
    statsd_batch.gauge("boinc.stat.update_time",bench_time[0].total)
    statsd_batch.flush
  end
end