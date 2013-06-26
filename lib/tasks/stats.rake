namespace :stats do
  task :update_all => :environment do
    Rake::Task["stats:update_general"].execute
    Rake::Task["stats:update_alliances"].execute
    Rake::Task["stats:update_trophy"].execute
  end
  desc "copy stats into general"
  task :update_general => :environment do
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
            total_credits = stat.nereus_credit.to_i+stat.boinc_credit.to_i+stat.total_bonus_credit
            #todo add average credit to general update
            avg_daily_credit = stat.nereus_daily.to_i+stat.boinc_daily.to_i
            upsert.row({:id => stat.id}, :total_credit => total_credits, :updated_at => Time.now, :created_at => Time.now)
            upsert.row({:id => stat.id}, :recent_avg_credit=>avg_daily_credit, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.credit",total_credits)
            statsd_batch.gauge("general.users.#{GraphitePathModule.path_for_stats(stat.profile_id)}.avg_daily_credit",avg_daily_credit)
            total_daily_credits += avg_daily_credit
          end

          #recorded total tflops reading
          total_tflops = SiteStat.get("nereus_TFLOPS").value.to_i + SiteStat.get("boinc_TFLOPS").value.to_i
          SiteStat.set("global_TFLOPS",(total_tflops).round(2))
        end
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

  desc "copy users credits into alliance credit"
  task :update_alliances => :environment do
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update credit alliance member items') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        connection.query("UPDATE alliance_members
                          INNER JOIN general_stats_items ON general_stats_items.profile_id = alliance_members.profile_id
                          SET alliance_members.leave_credit = general_stats_items.total_credit
                          WHERE alliance_members.leave_date IS NULL")
      }

      bench.report('update credit alliance') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :alliances

        alliances_credit = Alliance.temp_credit
        alliances_rac_total = Alliance.temp_rac
        Upsert.batch(connection,table_name) do |upsert|
          alliances_rac_total.each do |alliance|
            upsert.row({:id => alliance.id},:RAC => alliance.temp_rac, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.daily_credit",alliance.temp_rac)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.current_members",alliance.total_members)
          end
          alliances_credit.each do |alliance|
            credit = alliance.temp_credit
            upsert.row({:id => alliance.id}, :credit => credit, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.total_credit",credit)
          end
        end
      }

      bench.report('update rank alliance') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :alliances
        rank = 1
        alliances = Alliance.ranked
        Upsert.batch(connection,table_name) do |upsert|
          alliances.each do |alliance|
            upsert.row({:id => alliance.id}, :ranking => rank, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.rank", rank)
            rank += 1
          end
        end

      }
      statsd_batch.flush
    end
  end

  desc "updates credits trophies"
  task :update_trophy => :environment do
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update trophies') {
        #load all trophies
        all_trophies = Trophy.where("credits IS NOT NULL").order("credits ASC")
        trophies_credit_only = Trophy.where("credits IS NOT NULL").order("credits ASC").pluck(:credits)

        #load all profiles with general stats data
        profiles = Profile.for_trophies

        #check through all profiles adding upsert where needed and adding new profiles_trophies items
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :general_stats_items
        profiles_trophies_inserts = []
        Upsert.batch(connection,table_name) do |upsert|
          profiles.each do |profile|
            changed = false
            trophy_index  = trophies_credit_only.index(profile.last_trophy_credit_value.to_i)
            #check for new users with no existing trophy ie last_trophy_credit_value = 0
            trophy_index = trophy_index == nil ? -1: trophy_index
            required_for_next = all_trophies[trophy_index+1].try(:credits)
            while required_for_next != nil && required_for_next.to_i < profile.credits.to_i
              changed = true
              trophy_index += 1
              #add values to profiles_trophies (trophy_id,profile_id)
              profiles_trophies_inserts.push("(#{all_trophies[trophy_index].id}, #{profile.id}, '#{Time.now}', '#{Time.now}')")
              required_for_next = all_trophies[trophy_index+1].try(:credits)
            end
            if changed
              upsert.row({:id => profile.stats_id}, :last_trophy_credit_value => all_trophies[trophy_index].credits, :updated_at => Time.now, :created_at => Time.now)
            end
          end

        end
        #add new rows to profiles_trophies
        if profiles_trophies_inserts != []
          sql = "INSERT INTO profiles_trophies (trophy_id , profile_id, created_at, updated_at) VALUES #{profiles_trophies_inserts.join(", ")}"
          db_conn = ActiveRecord::Base.connection
          db_conn.execute sql
         #print sql
        end

      }

      statsd_batch.flush
    end
  end
end