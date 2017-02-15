class BoincJob < Delayed::BaseScheduledJob
  run_every 1.hour

  def perform
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('stats') {
        total_credit = 0
        total_RAC = 0
        users_with_RAC = 0
        total_users = 0

        # For each batch of remote users
        BoincRemoteUser.select([:id,:total_credit,:expavg_credit]).where('total_credit > 0 and expavg_credit > 0').find_in_batches do |remote_user|
          # For each remote user in the batch

          # Grab the associated stats item for each user in the batch
          boinc_local_items = BoincStatsItem.where{(boinc_id <= remote_user.max_by(&:id)) & (boinc_id >= remote_user.min_by(&:id))}
          boinc_hash = Hash[*boinc_local_items.map{|b| [b.boinc_id, b]}.flatten]

          BoincStatsItem.transaction do
            remote_user.each do |remote|
              local = boinc_hash[remote.id]

              if local.nil?
                # Don't make a new boinc stats item if it's not associated with a user.
                # Let the BoincCopyJob do that.
                next
              end

              # Has this one changed?
              changed = (local.credit == remote.total_credit && local.RAC == remote.expavg_credit) ? false : true

              total_credit += remote.total_credit
              total_RAC += remote.expavg_credit
              users_with_RAC += (remote.expavg_credit > 10) ? 1 : 0
              total_users += 1

              if changed
                local.credit = remote.total_credit
                local.RAC = remote.expavg_credit
                local.save

                statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(remote.id)}.credit",remote.total_credit)
                statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(remote.id)}.rac",remote.expavg_credit)
                statsd_batch.flush
              end
            end
          end
        end
=begin
        BoincRemoteUser.select([:id,:total_credit,:expavg_credit]).where('total_credit > 0 and expavg_credit > 0').find_in_batches do |boinc_remote|
          boinc_local_items = BoincStatsItem.where{(boinc_id <= boinc_remote.max_by(&:id)) & (boinc_id >= boinc_remote.min_by(&:id))}
          boinc_hash = Hash[*boinc_local_items.map{|b| [b.boinc_id, b]}.flatten]
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
              statsd_batch.flush
              sleep(0.0001)
	            #statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.jobs", BoincResult.total_in_progress(id))
              #statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.pending_jobs", BoincResult.total_pending(id))
              #statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.connected_copmuters_count", BoincResult.running_computers(id))
              local.save
            end
          end
       end
=end

        statsd_batch.gauge("boinc.stat.total_credit",total_credit)
        statsd_batch.gauge("boinc.stat.total_rac",total_RAC)
        SiteStat.set("boinc_TFLOPS",(total_RAC*0.000005).round(2))
        statsd_batch.gauge("boinc.stat.total_users",total_users)
        statsd_batch.gauge("boinc.stat.active_users",users_with_RAC)
        statsd_batch.flush

      }
    end
    puts bench_time.to_yaml
    statsd_batch.gauge("boinc.stat.update_time",bench_time[0].total)
    statsd_batch.flush
  end
end
