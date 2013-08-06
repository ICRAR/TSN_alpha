class StatsGeneralJob
  include Delayed::ScheduledJob
  run_every 1.minutes
  def perform
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    total_daily_credits = 0
    bench_time = Benchmark.bm do |bench|
      bench.report('copy credit user') {
        #start direct connection to DB for upsert
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :general_stats_items

        combined_credits = GeneralStatsItem.for_update_credits
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          combined_credits.each do |stat|
            #******* THIS LINE IS WHERE CREDITS********
            total_credits = stat.nereus_credit.to_i+stat.boinc_credit.to_i+stat.total_bonus_credit.to_i
            avg_daily_credit = stat.nereus_daily.to_i+stat.boinc_daily.to_i
            upsert.row({:id => stat.id}, :total_credit => total_credits, :updated_at => Time.now, :created_at => Time.now)
            upsert.row({:id => stat.id}, :recent_avg_credit=>avg_daily_credit, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.credit",total_credits)
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.avg_daily_credit",avg_daily_credit)
            total_daily_credits += avg_daily_credit
          end

          #recorded total tflops reading
          total_tflops = SiteStat.get("nereus_TFLOPS").value.to_f + SiteStat.get("boinc_TFLOPS").value.to_f
          SiteStat.set("global_TFLOPS",(total_tflops).round(2))
        end
      }
      bench.report('site stats') {
        #recorded total tflops reading
        total_tflops = SiteStat.get("nereus_TFLOPS").value.to_f + SiteStat.get("boinc_TFLOPS").value.to_f
        SiteStat.set("global_TFLOPS",(total_tflops).round(2))


        #Total Credit since beginning
        total_credit = GeneralStatsItem.sum(:total_credit)
        SiteStat.set("total_credit",total_credit)

        # total new members in the last month
        new_users_month = User.where{confirmed_at > 1.month.ago}.count
        SiteStat.set("new_users_month",new_users_month)

        #number of new trophies in the last month
        new_trophies_month = ProfilesTrophy.where{created_at > 1.month.ago}.count
        SiteStat.set("new_trophies_month",new_trophies_month)

        #number of new alliance members in the last month
        new_alliance_members_month = AllianceMembers.where{join_date > 1.month.ago}.count
        SiteStat.set("new_alliance_members_month",new_alliance_members_month)

        #time since first launch
        days_since_start = ((Time.now - Time.parse('13/09/2011'))/1.day).round
        SiteStat.set("days_since_start",days_since_start)

        #time since first launch
        days_to_launch = ((Time.parse('13/09/2013')-Time.now)/1.day).round
        SiteStat.set("days_to_launch",days_to_launch)

        #number of galaxies currently being processed
        galaxies_running = Galaxy.num_current
        SiteStat.set("galaxies_running",galaxies_running)


      }
      bench.report('update ranks user') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :general_stats_items

        stats = GeneralStatsItem.has_credit
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          rank = 1
          stats.each do |stat|
            upsert.row({:id => stat.id}, :rank => rank, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.rank",rank)
            rank += 1
          end
        end

        stats = GeneralStatsItem.no_credit
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          stats.each do |stat|
            upsert.row({:id => stat.id}, :rank => nil, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.rank",0)
          end
        end
      }
    end
  end
end