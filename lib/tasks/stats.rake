namespace :stats do

  desc "loads data from external site"
  task :update_boinc => :environment do
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|


      bench.report('1') {
        #load xml file (note is gziped for size)
        remote_file = Zlib::GzipReader.new(open(APP_CONFIG['boinc_url']+APP_CONFIG['boinc_users_xml']))
        xml = Nokogiri::XML(remote_file)

        #start direct connection to DB for upsert
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
        table_name = :boinc_stats_items

        #total credit and total RAC
        total_credit = 0
        total_RAC = 0
        users_with_RAC = 0
        #start statsd batch


        # Slice xml file into parts to speed up processing
        # Performance test varying slice size shoes that ~100 is appropriate
        # user     system      total        real
        #1 11.990000   0.760000  12.750000 ( 15.287818)
        #10  2.060000   0.380000   2.440000 (  4.183381)
        #100  0.960000   0.340000   1.300000 (  2.978770)
        #1000  0.800000   0.380000   1.180000 (  2.886246)
        xml.xpath('//user').each_slice(100) do |group|



          #start upsert batch for this slice
          Upsert.batch(connection,table_name) do |upsert|
            group.each do |user|
              #grab user data from xml file
              name, id, credit, RAC = user.xpath('./name','./id','./total_credit','./expavg_credit').map{|x| x.text.strip.to_i}
              total_credit += credit
              total_RAC += RAC
              users_with_RAC += (RAC > 10) ? 1 : 0
              #update DB object
              upsert.row({:boinc_id => id}, :credit => credit, :RAC => RAC, :updated_at => Time.now, :created_at => Time.now)
              #send to statsd
              statsd_batch.gauge("boinc.users.#{id}.credit",credit)
              statsd_batch.gauge("boinc.users.#{id}.rac",RAC)
            end
          end


        end
        statsd_batch.gauge("boinc.stat.total_credit",total_credit)
        statsd_batch.gauge("boinc.stat.total_rac",total_RAC)
        statsd_batch.gauge("boinc.stat.total_users",xml.xpath('//user').size)
        statsd_batch.gauge("boinc.stat.active_users",users_with_RAC)
        statsd_batch.flush
      }
    end
    statsd_batch.gauge("boinc.stat.update_time",bench_time[0].total)
    statsd_batch.flush
  end

  desc "copy stats into general"
  task :update_general => :environment do

    bench_time = Benchmark.bm do |bench|
      bench.report('copy credit') {
        #start direct connection to DB for upsert
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
        table_name = :general_stats_items

        boinc_stats = BoincStatsItem.connected
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          boinc_stats.each do |stat|
            upsert.row({:id => stat.general_stats_item_id}, :total_credit => stat.credit, :recent_avg_credit => stat.RAC, :updated_at => Time.now, :created_at => Time.now)
          end
        end
      }

      bench.report('update ranks') {
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
        table_name = :general_stats_items

        stats = GeneralStatsItem.ranked
        #start upsert batch for all
        Upsert.batch(connection,table_name) do |upsert|
          rank = 1
          stats.each do |stat|
            upsert.row({:id => stat.id}, :rank => rank, :updated_at => Time.now, :created_at => Time.now)
            rank += 1
          end
        end
      }
    end
  end

  desc "copy users credits into alliance credit"
  task :update_alliances => :environment do
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update credit') {
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
        table_name = :alliances

        alliances = Alliance.temp_credit
        Upsert.batch(connection,table_name) do |upsert|
          alliances.each do |alliance|
            upsert.row({:id => alliance.id}, :credit => alliance.temp_credit, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("alliance.#{alliance.id}.credit",alliance.temp_credit)
            statsd_batch.gauge("alliance.#{alliance.id}.total_members",alliance.total_members)
          end
        end
      }

      bench.report('update rank') {
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
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
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
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