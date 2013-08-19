class NereusJob
  include Delayed::ScheduledJob
  run_every 1.hour

  def perform
    #start statsd batch
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)

    #connect to remote db
    remote_client =  NereusStatsItem.connect_to_backend_db

    #start direct connection to local DB for upsert
    connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    table_name = :nereus_stats_items

    id_range =  "`skynetID` >= 10000 AND `skynetID` <= 900000"

    #reset counters
    #total credit and total RAC
    total_credit = 0
    total_daily_credit = 0
    total_user = 0
    total_monthly_download = 0
    total_online_now = 0
    total_online_today = 0
    total_mips_now = 0
    total_mips_today = 0
    total_active = 0
    users_with_daily_credit = 0

    #hashes for storing data throughout update process
    nereus_all_hash = Hash.new
    nereus_update_hash = Hash.new


    bench_time = Benchmark.bm do |bench|

      #loads local database into memory
      bench.report('load_local') {
        nereus_all = connection.query("SELECT nereus_stats_items.* FROM nereus_stats_items", :as => :hash)
        nereus_all_hash = Hash[*nereus_all.map{|it| [it["nereus_id"], it]}.flatten]
      }

      #gets total credit from remote db
      bench.report('get totals') {
        #get remote usage data
        results = remote_client.query("SELECT `skynetID`,
                                        SUM(CEILING(
                                          (`uploaded`+`downloaded`)/15728640 +
                                          (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                        )) as credits
                                      FROM `dailyaccountusage` WHERE  #{id_range} GROUP BY `skynetID` ",
                                      :cache_rows => false)

        #iterate across results and update local data
        #start upsert batch for this slice
        results.each do |row|
          id = row['skynetID'].to_i
          #credits = credits for network + credit for time
          credit = row['credits']
          credit = credit.to_i * APP_CONFIG['nereus_to_credit_conversion']
          total_credit += credit
          #update DB object
          if credit > 0
            nereus_update_hash[id] = Hash.new unless nereus_update_hash.has_key?(id)
            #for unknowen reasons the data sometimes reports lower than expected credit values
            #if this is the case ignore this update
            old_credit = nereus_all_hash[id] ? nereus_all_hash[id]["credit"] : 0
            credit = [credit,old_credit].max
            nereus_update_hash[id][:credit] = credit
            total_user += 1
          end
          #send to statsd
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.credit",credit)
        end
        statsd_batch.gauge("nereus.stats.total_credit",total_credit)
        statsd_batch.gauge("nereus.stats.total_user",total_user)
      }

      #gets average of last 2 days credit from remote db similar to boinc's RAC system
      bench.report('get daily') {
        #then estimate daily credits
        #get usage data for today (part of) and yesterday (full)
        results = remote_client.query("SELECT `skynetID`,
                                        SUM(CEILING(
                                          (`uploaded`+`downloaded`)/15728640 +
                                          (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                        )) as credits
                                        FROM `dailyaccountusage` WHERE  #{id_range}
                                        AND (day = #{((Time.now.to_i)/86400).to_i} OR day = #{((Time.now.to_i)/86400 -1).to_i}) GROUP BY `skynetID`",
                                      :cache_rows => false)

        #get percentage of today and yesterday
        per_day = Time.now.hour/48.0 + Time.now.min/(48.0*60.0) + 0.5

        #iterate across results and update local data
        results.each do |row|
          id = row['skynetID'].to_i
          credit_to_now =  row['credits'].to_i * APP_CONFIG['nereus_to_credit_conversion']
          daily_credit =  (credit_to_now / per_day / 2 ).to_i  #esitmate for 2 full days then divided by 2 to get daily average
          total_daily_credit += daily_credit
                                                              #update DB object
          if  daily_credit > 0
            nereus_update_hash[id] = Hash.new unless nereus_update_hash.has_key?(id)
            nereus_update_hash[id][:daily_credit] = daily_credit
            users_with_daily_credit += 1
          end
                                                              #send to statsd
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.daily_credit",daily_credit)
        end

        statsd_batch.gauge("nereus.stats.total_daily_credit",total_daily_credit)
        SiteStat.set("nereus_TFLOPS",(total_daily_credit*0.000005).round(2))
        statsd_batch.gauge("nereus.stats.users_with_daily_credit",users_with_daily_credit)
      }

      #updates monthly network usage from remote db
      bench.report('get monthly_network_usage') {
        #get usage data
        results = remote_client.query("SELECT `skynetID`,
                                        SUM(CEILING(`uploaded`+`downloaded`)) as monthly_download
                                      FROM `dailyaccountusage` WHERE  #{id_range}
                                      AND YEAR(date) = #{Time.now.year} AND MONTH(date) = #{Time.now.month}
                                      GROUP BY `skynetID` ",
                                      :cache_rows => false)
        #iterate across results and update local data
        results.each do |row|
          id = row['skynetID'].to_i
          monthly_download = row['monthly_download']
          monthly_download = monthly_download.to_i
          total_monthly_download += monthly_download
          #update DB object
          nereus_update_hash[id] = Hash.new unless nereus_update_hash.has_key?(id)
          nereus_update_hash[id][:monthly_network_usage] = monthly_download

          #send to statsd
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.monthly_download",monthly_download)
        end
        #send global to statsd
        statsd_batch.gauge("nereus.stats.total_monthly_download",total_monthly_download)

        #we need to check for users who need to have the account network usage set to 0
        #as the will not show up in the above list

        nereus_update_hash.each do |key,value|
          value[:monthly_network_usage] ||= 0
        end
      }
      #updates account status for each account
      bench.report('get acount_status') {
        #get account data
        results = remote_client.query("SELECT *
                                      FROM  `accountstatus`
                                      WHERE  #{id_range}",
                                      :cache_rows => false)

        #iterate across results and update local data
        results.each do |row|
          id = row['skynetID'].to_i
          online_now = row['onlineNow'].to_i
          online_today = row['onlineToday'].to_i
          mips_now = row['mipsNow'].to_i
          mips_today = row['mipsToday'].to_i
          active = row['active'].to_i
          #update DB object
          nereus_update_hash[id] = Hash.new unless nereus_update_hash.has_key?(id)
          nereus_update_hash[id][:online_now] = online_now
          nereus_update_hash[id][:online_today] = online_today
          nereus_update_hash[id][:mips_now] = mips_now
          nereus_update_hash[id][:mips_today] = mips_today
          nereus_update_hash[id][:active] = active
          #send to statsd
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.online_now",online_now)
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.online_today",online_today)
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.mips_now",mips_now)
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.mips_today",mips_today)

          #update totals
          total_online_now +=  online_now
          total_online_today += online_today
          total_mips_now += mips_now
          total_mips_today += mips_today
        end
        #send totals to stats
        statsd_batch.gauge("nereus.stats.total_online_now",total_online_now)
        statsd_batch.gauge("nereus.stats.total_online_today",total_online_today)
        statsd_batch.gauge("nereus.stats.total_mips_now",total_mips_now)
        statsd_batch.gauge("nereus.stats.total_mips_today",total_mips_today)
      }
      #update active status + check network usage
      #also updates active status in remote db as well
      bench.report('update active status') {
        #Upsert.batch(remote_client,'accountstatus') do |upsert|
        nereus_update_hash.each do |item|
          id = item[0].to_i
          update_row = item[1] #fix for using hashes as array
          old_row = nereus_all_hash[item[0].to_i] #from local db
          if old_row == nil
            active = 0
          else
            active = (( old_row['network_limit'].to_i == 0 || (update_row[:monthly_network_usage].to_i < old_row['network_limit'].to_i))  && old_row['paused'].to_i == 0) ? 1 : 0
          end
          total_active += active
                               #only update old db if active status has changed
          if active != update_row[:active]
            #upsert.row({:skynetID => item[0]}, :active => active)
          end
          nereus_update_hash[id] = Hash.new unless nereus_update_hash.has_key?(id)
          nereus_update_hash[id][:active] = active
          statsd_batch.gauge("nereus.users.#{GraphitePathModule.path_for_stats(id)}.active",active)

        end
        #end
        #send totals to stats
        statsd_batch.gauge("nereus.stats.total_active",total_active)
      }
      bench.report('save all') {

        #start upsert batch for this slice
        Upsert.batch(connection,table_name) do |upsert|
          nereus_update_hash.each do |item|
            update_row = item[1] #fix for using hashes as array
            update_row[:daily_credit] ||= 0
            update_row[:updated_at] =  Time.now
            update_row[:created_at] =  Time.now
            upsert.row({:nereus_id => item[0].to_i}, update_row)
          end
        end
      }


    end
    statsd_batch.gauge("nereus.stats.update_time",bench_time.inject(0){|sum,n| sum + n.total})
    statsd_batch.flush
  end
end