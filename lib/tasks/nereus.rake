namespace :nereus do

  desc "loads data from external site"
  task :update_nereus => :environment do
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)

    #connect to remote db
    #todo add nerus data too config file
    remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host'], :username => APP_CONFIG['nereus_username'], :database => APP_CONFIG['nereus_database'], :password => APP_CONFIG['nereus_password'])

    #start direct connection to local DB for upsert
    connection = PG.connect(:host => Rails.configuration.database_configuration[Rails.env]["host"],:port => Rails.configuration.database_configuration[Rails.env]["port"],:dbname => Rails.configuration.database_configuration[Rails.env]["database"],:user => Rails.configuration.database_configuration[Rails.env]["username"],:password => Rails.configuration.database_configuration[Rails.env]["password"])
    table_name = :nereus_stats_items

    #first update the total credit numbers

    #total credit and total RAC
    total_credit = 0
    total_daily_credit = 0
    total_user = 0
    users_with_daily_credit = 0

    bench_time = Benchmark.bm do |bench|



      bench.report('totals') {



          #get usage data
          results = remote_client.query("SELECT `skynetID`, sum(`uploaded`) as uploaded, sum(`downloaded`) as downloaded, sum(`millisecondsOnline`) as online, sum(`millisecondsDisabled`) as offline FROM `dailyaccountusage` WHERE  `skynetID` >= 100000 AND `skynetID` <= 900000 GROUP BY `skynetID` ", :cache_rows => false)

          #iterate across results and update local data
          #start upsert batch for this slice
          Upsert.batch(connection,table_name) do |upsert|
            results.each do |row|
              id = row['skynetID'].to_i
              #credits = credits for network + credit for time
              credit = (row['uploaded'].to_i + row['downloaded'].to_i)/15728640.0 + (row['online'].to_i - row['offline'].to_i)/900000.0
              credit = credit.to_i
              total_credit += credit
              #update DB object
              if credit > 0
                upsert.row({:nereus_id => id}, :credit => credit, :updated_at => Time.now, :created_at => Time.now)
                total_user += 1
              end
              #send to statsd
              statsd_batch.gauge("nereus.users.#{id}.credit",credit)
            end
          end
      }
      bench.report('daily') {
        #then estimate daily credits
          Time
          #get usage data for today (part of) and yesterday (full)
          results = remote_client.query("SELECT `skynetID`, sum(`uploaded`) as uploaded, sum(`downloaded`) as downloaded, sum(`millisecondsOnline`) as online, sum(`millisecondsDisabled`) as offline  FROM `dailyaccountusage` WHERE  `skynetID` >= 100000 AND `skynetID` <= 900000 AND (day = #{(Time.now.to_i+8*60*60)/86400} OR day = #{(Time.now.to_i+8*60*60)/86400 -1}) GROUP BY `skynetID`", :cache_rows => false)

          #get percentage of today and yesterday
          per_day = Time.now.hour/48.0 + Time.now.min/(48.0*60.0) + 0.5

          #iterate across results and update local data
          #start upsert batch for this slice
          Upsert.batch(connection,table_name) do |upsert|
            results.each do |row|
              id = row['skynetID'].to_i
              #credits = credits for network + credit for time
              credit_to_now = (row['uploaded'].to_i + row['downloaded'].to_i)/15728640.0 + (row['online'].to_i - row['offline'].to_i)/900000.0
              daily_credit =  (credit_to_now / per_day /2 ).to_i  #esitmate for 2 full days then divided by 2 to get daily average
              total_daily_credit += daily_credit
              #update DB object
              if  daily_credit > 0
                upsert.row({:nereus_id => id}, :daily_credit => daily_credit, :updated_at => Time.now, :created_at => Time.now)
                users_with_daily_credit += 1
              end
              #send to statsd
              statsd_batch.gauge("nereus.users.#{id}.daily_credit",daily_credit)
            end
          end

        statsd_batch.gauge("nereus.stats.total_credit",total_credit)
        statsd_batch.gauge("nereus.stats.total_user",total_user)
        statsd_batch.gauge("nereus.stats.total_daily_credit",total_daily_credit)
        statsd_batch.gauge("nereus.stats.users_with_daily_credit",users_with_daily_credit)
      }
    end

    statsd_batch.gauge("nereus.stats.update_time",bench_time[0].total+bench_time[1].total)
    statsd_batch.flush

  end

end