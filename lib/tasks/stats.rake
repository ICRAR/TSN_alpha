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
    bench_time = Benchmark.bm do |bench|
      bench.report('copy credit user') {
        #start direct connection to DB for upsert
        connection = PG.connect(:host => Rails.configuration.database_configuration[Rails.env]["host"],:port => Rails.configuration.database_configuration[Rails.env]["port"],:dbname => Rails.configuration.database_configuration[Rails.env]["database"],:user => Rails.configuration.database_configuration[Rails.env]["username"],:password => Rails.configuration.database_configuration[Rails.env]["password"])
        table_name = :general_stats_items

        combined_credits = GeneralStatsItem.for_update_credits
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          combined_credits.each do |stat|
            total_credits = stat.nereus_credit.to_i+stat.boinc_credit.to_i
            #todo add average credit to general update
            upsert.row({:id => stat.id}, :total_credit => total_credits, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{stat.profile_id}.#{stat.id}.credit",total_credits)
          end
        end
      }

      bench.report('update ranks user') {
        connection = PG.connect(:host => Rails.configuration.database_configuration[Rails.env]["host"],:port => Rails.configuration.database_configuration[Rails.env]["port"],:dbname => Rails.configuration.database_configuration[Rails.env]["database"],:user => Rails.configuration.database_configuration[Rails.env]["username"],:password => Rails.configuration.database_configuration[Rails.env]["password"])
        table_name = :general_stats_items

        stats = GeneralStatsItem.has_credit
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          rank = 1
          stats.each do |stat|
            upsert.row({:id => stat.id}, :rank => rank, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{stat.profile_id}.#{stat.id}.rank",rank)
            rank += 1
          end
        end

        stats = GeneralStatsItem.no_credit
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          stats.each do |stat|
            upsert.row({:id => stat.id}, :rank => nil, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.users.#{stat.profile_id}.#{stat.id}.rank",0)
          end
        end
      }
    end
  end

  desc "copy users credits into alliance credit"
  task :update_alliances => :environment do
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update credit alliance') {
        connection = PG.connect(:host => Rails.configuration.database_configuration[Rails.env]["host"],:port => Rails.configuration.database_configuration[Rails.env]["port"],:dbname => Rails.configuration.database_configuration[Rails.env]["database"],:user => Rails.configuration.database_configuration[Rails.env]["username"],:password => Rails.configuration.database_configuration[Rails.env]["password"])
        table_name = :alliances

        alliances = Alliance.temp_credit
        Upsert.batch(connection,table_name) do |upsert|
          alliances.each do |alliance|
            upsert.row({:id => alliance.id}, :credit => alliance.temp_credit,:RAC => alliance.temp_rac, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("alliance.#{alliance.id}.credit",alliance.temp_credit)
            statsd_batch.gauge("alliance.#{alliance.id}.rac",alliance.temp_rac)
            statsd_batch.gauge("alliance.#{alliance.id}.total_members",alliance.total_members)
          end
        end
      }

      bench.report('update rank alliance') {
        connection = PG.connect(:host => Rails.configuration.database_configuration[Rails.env]["host"],:port => Rails.configuration.database_configuration[Rails.env]["port"],:dbname => Rails.configuration.database_configuration[Rails.env]["database"],:user => Rails.configuration.database_configuration[Rails.env]["username"],:password => Rails.configuration.database_configuration[Rails.env]["password"])
        table_name = :alliances
        rank = 1
        alliances = Alliance.ranked
        Upsert.batch(connection,table_name) do |upsert|
          alliances.each do |alliance|
            upsert.row({:id => alliance.id}, :ranking => rank, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("alliance.#{alliance.id}.rank", rank)
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
        connection = PG.connect(:host => Rails.configuration.database_configuration[Rails.env]["host"],:port => Rails.configuration.database_configuration[Rails.env]["port"],:dbname => Rails.configuration.database_configuration[Rails.env]["database"],:user => Rails.configuration.database_configuration[Rails.env]["username"],:password => Rails.configuration.database_configuration[Rails.env]["password"])
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
              profiles_trophies_inserts.push("(#{all_trophies[trophy_index].id}, #{profile.id})")
              required_for_next = all_trophies[trophy_index+1].try(:credits)
            end
            if changed
              upsert.row({:id => profile.stats_id}, :last_trophy_credit_value => all_trophies[trophy_index].credits, :updated_at => Time.now, :created_at => Time.now)
            end
          end

        end
        #add new rows to profiles_trophies
        if profiles_trophies_inserts != []
          sql = "INSERT INTO profiles_trophies (trophy_id , profile_id) VALUES #{profiles_trophies_inserts.join(", ")}"
          db_conn = ActiveRecord::Base.connection
          db_conn.execute sql
        end

      }

      statsd_batch.flush
    end
  end
end