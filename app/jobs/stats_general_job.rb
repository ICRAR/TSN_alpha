class StatsGeneralJob
  include Delayed::ScheduledJob
  run_every 1.hour
  def perform
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    total_daily_credits = 0
    bench_time = Benchmark.bm do |bench|
      bench.report('copy credit user') {
        #load From DB
        combined_credits = GeneralStatsItem.for_update_credits
        #add credits and record totals
        combined_credits.each do |stat|
          total_credits = stat.nereus_credit.to_i+stat.boinc_credit.to_i+stat.total_bonus_credit.to_i
          avg_daily_credit = stat.nereus_daily.to_i+stat.boinc_daily.to_i
          stat.total_credit = total_credits
          stat.recent_avg_credit = avg_daily_credit
          statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.credit",total_credits)
          statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.avg_daily_credit",avg_daily_credit)
          total_daily_credits += avg_daily_credit
        end

        #sort by total credit
        combined_credits.sort! {|a,b| b.total_credit <=> a.total_credit}
        i = 1

        #update ranks and load to DB
        GeneralStatsItem.transaction do
          combined_credits.each do |stat|
            if stat.total_credit > 0 && stat.power_user == false
              stat.rank = i
              i += 1
            else
              stat.rank = nil
            end
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.rank",stat.rank)
            stat.save()
          end
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
        new_users_month = User.where{joined_at > 1.month.ago}.count
        SiteStat.set("new_users_month",new_users_month)

        #number of new trophies in the last month
        new_trophies_month = ProfilesTrophy.where{created_at > 1.month.ago}.count
        SiteStat.set("new_trophies_month",new_trophies_month)

        #number of new alliance mhttp://eterna.cmu.edu/game/puzzle/13375/embers in the last month
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

        #number of galaxies currently being processed
        galaxies_queued = GalaxyRegister.where{create_time == nil}.count
        SiteStat.set("galaxies_queued",galaxies_queued)

        #number of user signed in the last:
        users_1_day = User.where{current_sign_in_at > 1.day.ago}.count
        users_1_week = User.where{current_sign_in_at > 1.week.ago}.count
        users_1_month = User.where{current_sign_in_at > 1.month.ago}.count
        users_1_year = User.where{current_sign_in_at > 1.year.ago}.count
        SiteStat.set("users_1_day",users_1_day)
        SiteStat.set("users_1_week",users_1_week)
        SiteStat.set("users_1_month",users_1_month)
        SiteStat.set("users_1_year",users_1_year)

        #users with sign_in_count
        total_sign_in_count = User.sum(:sign_in_count)
        avg_sign_in_count = (User.sum(:sign_in_count) / User.where{sign_in_count > 0}.count).to_i
        SiteStat.set("total_sign_in_count",total_sign_in_count)
        SiteStat.set("avg_sign_in_count",avg_sign_in_count)

        #num of users who have signed in x times:
        users_more_than_0 =  User.where{sign_in_count > 0}.count
        users_more_than_1 =  User.where{sign_in_count > 1}.count
        users_more_than_10 =  User.where{sign_in_count > 10}.count
        users_more_than_50 =  User.where{sign_in_count > 50}.count
        users_more_than_100 =  User.where{sign_in_count > 100}.count
        users_more_than_200 =  User.where{sign_in_count > 200}.count
        users_more_than_500 =  User.where{sign_in_count > 500}.count
        SiteStat.set("users_more_than_0",users_more_than_0)
        SiteStat.set("users_more_than_1",users_more_than_1)
        SiteStat.set("users_more_than_10",users_more_than_10)
        SiteStat.set("users_more_than_50",users_more_than_50)
        SiteStat.set("users_more_than_100",users_more_than_100)
        SiteStat.set("users_more_than_200",users_more_than_200)
        SiteStat.set("users_more_than_500",users_more_than_500)






      }
    end
  end
end