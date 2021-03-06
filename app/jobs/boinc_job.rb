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
                puts 'No boinc stats item found! Run BoincCopyJob!'
                next
              end

              # Has this one changed?
              puts "Credit Local: #{local.credit} Remote: #{remote.total_credit}"
              puts "RAC Local: #{local.RAC} Remote: #{remote.expavg_credit}"

              # Convert to integer because local stores credit and RAC as ints.
              changed = (local.credit == remote.total_credit.to_i && local.RAC == remote.expavg_credit.to_i) ? false : true

              total_credit += remote.total_credit
              total_RAC += remote.expavg_credit
              users_with_RAC += (remote.expavg_credit > 10) ? 1 : 0
              total_users += 1

              if changed
                puts 'Credit changed, updating...'
                local.credit = remote.total_credit
                local.RAC = remote.expavg_credit
                local.save

                statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(remote.id)}.credit",remote.total_credit)
                statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(remote.id)}.rac",remote.expavg_credit)
              else
                puts 'Credit un-changed'
              end
            end
          end
          # Flush batches of users together
          statsd_batch.flush
        end

        statsd_batch.gauge("boinc.stat.total_credit",total_credit)
        statsd_batch.gauge("boinc.stat.total_rac",total_RAC)
        SiteStat.set("boinc_TFLOPS",(total_RAC*0.000005).round(2))
        statsd_batch.gauge("boinc.stat.total_users",total_users)
        statsd_batch.gauge("boinc.stat.active_users",users_with_RAC)
        statsd_batch.flush
        puts "Site stats: Total Credit: #{total_credit}, Total Rac: #{total_RAC}, Total Users: #{total_users}, Users with RAC: #{users_with_RAC}"
      }
    end
    puts bench_time.to_yaml
    statsd_batch.gauge("boinc.stat.update_time",bench_time[0].total)
    statsd_batch.flush
  end
end
