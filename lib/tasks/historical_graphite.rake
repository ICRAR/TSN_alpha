namespace :historical_graphite do
  desc "loads data from external site"
  task :test => :environment do
    #connect to remote db
    remote_client =  NereusStatsItem.connect_to_backend_db
    remote_client_front_end = Mysql2::Client.new(:host => APP_CONFIG['nereus_host_front_end'], :username => APP_CONFIG['nereus_username_front_end'], :database => APP_CONFIG['nereus_database_front_end'], :password => APP_CONFIG['nereus_password_front_end'])
    main_db = ActiveRecord::Base.connection

    @today = Time.now.to_i/86400

    print "Starting histroical graphite run ********* \n"
    bench_time = Benchmark.bm do |bench|
      bench.report('create ranks graphs') {
        ranks(remote_client)
      }

      bench.report('create user graphs') {
        users = NereusStatsItem.all
        users.each do |user|
          print "update user id:#{user.nereus_id} \n"
          load_nereus_user(user.nereus_id,remote_client)
        end
      }

      bench.report('create total graphs') {
        load_nereus_totals(remote_client)
      }

      bench.report('load Alliance data') {
        #reset daily alliance table
        main_db.execute("DELETE FROM daily_alliance_credit WHERE 1=1")
        load_all_alliance_days(main_db,remote_client_front_end)
      }

      bench.report('update alliance ranks') {
        create_graphite_alliance_ranks(main_db)
      }

      bench.report('update allaince graphs') {
        create_graphite_alliance_graphs(main_db)
      }

    end
  end
end


#Takes a user ID and DB connection
#and forms a whisper query for historical credit
def load_nereus_user(user_id,db_con)
  results = db_con.query("select t1.skynetID,  t1.day, SUM(t2.credit) as sum_credit, t1.credit
                            from (SELECT skynetID,
                                         day ,
                                         CEILING(
                                            (`uploaded`+`downloaded`)/15728640 +
                                            (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                          ) as credit
                                  FROM dailyaccountusage WHERE skynetID = #{user_id}
                                ) as t1
                            inner join (SELECT skynetID,
                                         day ,
                                         CEILING(
                                            (`uploaded`+`downloaded`)/15728640 +
                                            (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                          ) as credit
                                  FROM dailyaccountusage WHERE skynetID = #{user_id}
                            ) as t2 on t1.day >= t2.day
                            GROUP BY t1.day
                            order by t1.day asc",
                                :cache_rows => true)

  query_total = ""
  query_daily = ""
  if results.first != nil
    day = results.first['day'].to_i
    last_credit =   results.first['sum_credit'].to_i* APP_CONFIG['nereus_to_credit_conversion']
    current_day = 0
    results.each do |row|
      current_day = row['day'].to_i
      while  current_day > day
        query_total << " #{day_to_timestamp(day)}:#{last_credit}"
        query_daily << " #{day_to_timestamp(day)}:#{0}"
        day += 1
      end
      last_credit = row['sum_credit'].to_i* APP_CONFIG['nereus_to_credit_conversion']
      query_total << " #{day_to_timestamp(current_day)}:#{last_credit}"
      query_daily << " #{day_to_timestamp(current_day)}:#{row['credit'].to_i* APP_CONFIG['nereus_to_credit_conversion']}"
      day += 1

    end
    today = @today
    while  current_day < today
      query_total << " #{day_to_timestamp(current_day)}:#{last_credit}"
      query_daily << " #{day_to_timestamp(current_day)}:#{0}"
      current_day += 1
    end

    path_to_storage = "/opt/graphite/storage/whisper/stats/gauges/TSN_dev/nereus/users/#{user_id}/"
    call_whisper(path_to_storage+'credit.wsp',query_total)
    call_whisper(path_to_storage+'daily_credit.wsp',query_daily)
  else
    print "-- skipping user: #{user_id}, we could not find them in the database"

  end
end

def load_nereus_totals(db_con)
  results = db_con.query("select t1.daily_users,  t1.day, SUM(t2.credit) as sum_credit, t1.credit
                            from (SELECT COUNT(skynetID) as daily_users,
                                         day ,
                                         SUM(CEILING(
                                            (`uploaded`+`downloaded`)/15728640 +
                                            (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                          )) as credit
                                  FROM dailyaccountusage WHERE `skynetID` >= 20000 AND `skynetID` <= 900000 GROUP BY day
                                ) as t1
                            inner join (SELECT skynetID,
                                         day ,
                                         SUM(CEILING(
                                            (`uploaded`+`downloaded`)/15728640 +
                                            (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                          )) as credit
                                  FROM dailyaccountusage WHERE `skynetID` >= 20000 AND `skynetID` <= 900000 GROUP BY day
                            ) as t2 on t1.day >= t2.day
                            GROUP BY t1.day
                            order by t1.day asc",
                         :cache_rows => true)

  query_total_credit = ""
  query_daily_credit = ""
  query_total_user = ""
  query_total_daily_user = ""


  results.each do |row|
    current_day = row['day'].to_i
    query_total_credit << " #{day_to_timestamp(current_day)}:#{row['sum_credit'].to_i* APP_CONFIG['nereus_to_credit_conversion']}"
    query_daily_credit << " #{day_to_timestamp(current_day)}:#{row['credit'].to_i* APP_CONFIG['nereus_to_credit_conversion']}"
    query_total_daily_user << " #{day_to_timestamp(current_day)}:#{row['daily_users'].to_i}"
  end

  results = db_con.query("SELECT t1.day, SUM(t2.new_users) as sum_users
                            FROM (
                              SELECT COUNT(DISTINCT  totals.`skynetID` ) as new_users ,
                                      totals.`day`
                                FROM (
                                  SELECT MIN(day) as day, skynetID
                                    FROM  `dailyaccountusage`
                                    WHERE `skynetID` >= 20000 AND `skynetID` <= 900000
                                    GROUP BY  `skynetID`
                                ) AS totals
                                GROUP BY  totals.`day`
                            ) as t1
                            inner join (
                              SELECT COUNT(DISTINCT  totals.`skynetID` ) as new_users ,
                                      totals.`day`
                                FROM (
                                  SELECT MIN(day) as day, skynetID
                                    FROM  `dailyaccountusage`
                                    WHERE `skynetID` >= 20000 AND `skynetID` <= 900000
                                    GROUP BY  `skynetID`
                                ) AS totals
                                GROUP BY  totals.`day`
                            ) as t2 on t1.day >= t2.day
                            GROUP BY t1.day
                            order by t1.day asc",
                         :cache_rows => true)
  day = results.first['day'].to_i
  last_total =   results.first['sum_users'].to_i
  results.each do |row|
    current_day = row['day'].to_i
    while  current_day > day
      query_total_user << " #{day_to_timestamp(day)}:#{last_total}"
      day += 1
    end
    last_total = row['sum_users'].to_i
    query_total_user << " #{day_to_timestamp(current_day)}:#{last_total}"
    day += 1
  end

  path_to_storage = "/opt/graphite/storage/whisper/stats/gauges/TSN_dev/nereus/stats/"
  call_whisper(path_to_storage+'total_credit.wsp',query_total_credit)
  call_whisper(path_to_storage+'total_daily_credit.wsp',query_daily_credit)
  call_whisper(path_to_storage+'total_user.wsp',query_total_user)
  call_whisper(path_to_storage+'users_with_daily_credit.wsp',query_total_daily_user)
end

def ranks(db_con)
  start_date = 15226
  end_date = @today
  #end_date = 15228
  users = Hash.new

  for day in start_date..end_date do
    print "getting day: #{day} \n"
    results = db_con.query("SELECT skynetID,
                                   SUM(CEILING(
                                      (`uploaded`+`downloaded`)/15728640 +
                                      (`millisecondsOnline`-`millisecondsDisabled`)/900000
                                    )) as total_credit
                                  FROM dailyaccountusage WHERE `skynetID` >= 20000 AND `skynetID` <= 900000 AND day <= #{day} GROUP BY skynetID
                            ORDER BY total_credit DESC",
                           :cache_rows => false)
    rank = 1
    results.each do |row|
      skynetID = row['skynetID'].to_i
      if users[skynetID] == nil
        users[skynetID] = Hash.new
        users[skynetID]['start_day'] = day
        users[skynetID]['ranks'] = Array.new
      end
      users[skynetID]['ranks'] << rank
      rank += 1
    end
  end

  users.each do |key, value|
    update_user_rank(key,value['start_day'],value['ranks'])
  end
end

def update_user_rank(user_id,start_day,rank_array)
  query_rank = ""
  day = start_day
  rank_array.each do |rank|
    query_rank << " #{day_to_timestamp(day)}:#{rank}"
    day += 1
  end
  profile = get_profile_by_nereus_id(user_id)
  if profile == nil
     print "***************** profile not found for nereus id #{user_id} ************** \n"
  else
    id = profile.id
    path_to_storage = "/opt/graphite/storage/whisper/stats/gauges/TSN_dev/general/users/#{id}/"
    call_whisper(path_to_storage+'rank.wsp',query_rank)
  end
end

def day_to_timestamp(day)
  day*86400
end

def call_whisper(path, query)
  path_to_whisper_update = "/usr/local/bin/whisper-update.py"
  path_to_whisper_create = "/usr/local/bin/whisper-create.py"
  store_scheme = "1h:7d 1d:10y"
  FileUtils.mkdir_p(File.dirname(path)) unless File.directory?(File.dirname(path))
  unless File.file?(path)
    system_query = "#{path_to_whisper_create} #{path} #{store_scheme}"
    print "-- creating file #{path} \n"
    system system_query + " > /dev/null"
  end
  system_query = "#{path_to_whisper_update} #{path}#{query}"
  print "-- updating file #{path} \n"
  system system_query + " > /dev/null"
end

def get_profile_by_nereus_id(nereus_id)
  n = NereusStatsItem.where(:nereus_id => nereus_id).first
  if n != nil && n.general_stats_item != nil
    n.general_stats_item.profile
  else
    nil
  end
end

def get_alliance_daily_credit(main_db,db_con,day,alliance_hash)

  results = db_con.query(
      " SELECT
          T2.teamID,
          Sum(T2.daily_credit) as daily_credits,
          Count(T2.userID) as total_members
        FROM
        (
          SELECT T.*,
            (
              SELECT credits
              FROM  `dailyCredits` WHERE  `dailyCredits`.`userID` = T.`userID`
                AND  `dailyCredits`.`day` = #{day}
            ) as daily_credit

            FROM `TeamList` T
            WHERE  `userID` >= 100000 AND `userID` <= 900000
              AND T.`joinTime` < '#{Time.at(day*86400)}'
              AND (T.`leaveTime`> '#{Time.at(day*86400)}' OR T.`leaveTime` is NULL)
        ) T2
        GROUP BY T2.teamID
      ",:cache_rows => false)
  daily_alliance_inserts = []

  results.each do |row|
    old_id = row['teamID'].to_i
    if alliance_hash[old_id] == nil
      alliance_hash[old_id] = Hash.new
      alliance_hash[old_id]['total_credit'] = 0
      a = Alliance.find_by_old_id(old_id)
      new_id = (a == nil) ? nil : a.id
      alliance_hash[old_id]['new_id'] = new_id
    else
      new_id = alliance_hash[old_id]['new_id']
    end

    if new_id != nil
      total_credits = alliance_hash[old_id]['total_credit'].to_i + row['daily_credits'].to_i* APP_CONFIG['nereus_to_credit_conversion']
      alliance_hash[old_id]['total_credit'] = total_credits
      daily_alliance_inserts.push("(#{new_id}, #{old_id}, #{day}, #{row['total_members'].to_i}, #{row['daily_credits'].to_i* APP_CONFIG['nereus_to_credit_conversion']}, #{total_credits})")
    end
  end

  if daily_alliance_inserts != []
    sql = "INSERT INTO daily_alliance_credit (alliance_id, old_alliance_id, day, current_members, daily_credit, total_credit) VALUES #{daily_alliance_inserts.join(", ")}"
    main_db.execute sql
    #print sql
  end

end
def load_all_alliance_days(main_db,remote_client_front_end)
  allaince_hash = Hash.new
  start_date = 15226
  end_date = @today
  for day in start_date..end_date do
    print "day: #{day} \n"
    get_alliance_daily_credit(main_db,remote_client_front_end,day,allaince_hash)

  end
end
def create_graphite_alliance_ranks(main_db)
  start_date = 15226
  end_date = @today
  #end_date = 15228
  alliances = Hash.new

  for day in start_date..end_date do
    print "getting day: #{day} \n"
    results = main_db.execute("SELECT * FROM daily_alliance_credit WHERE day = ' #{day}' ORDER BY total_credit DESC")
    rank = 1
    results.each do |row|
      id = row['alliance_id'].to_i
      if alliances[id] == nil
        alliances[id] = Hash.new
        alliances[id]['start_day'] = day
        alliances[id]['ranks'] = Array.new
      end
      alliances[id]['ranks'] << rank
      rank += 1
    end
  end

  alliances.each do |key, value|
    update_alliances_rank(key,value['start_day'],value['ranks'])
  end
end
def update_alliances_rank(alliance_id,start_day,rank_array)
  query_rank = ""
  day = start_day
  rank_array.each do |rank|
    query_rank << " #{day_to_timestamp(day)}:#{rank}"
    day += 1
  end
  path_to_storage = "/opt/graphite/storage/whisper/stats/gauges/TSN_dev/general/alliance/#{alliance_id}/"
  call_whisper(path_to_storage+'rank.wsp',query_rank)
end
def   create_graphite_alliance_graphs(main_db)
  list = main_db.execute("SELECT DISTINCT alliance_id FROM daily_alliance_credit")
  size = list.count
  i = 0
  list.each do |item|
    print "loading Alliance: #{item['alliance_id']}. #{i += 1}/#{size}\n"
    create_graphite_alliance_graphs_each(main_db,item['alliance_id'])
    print "\n"
  end

end
def create_graphite_alliance_graphs_each(main_db,alliance_id)
  result = main_db.execute("SELECT * FROM daily_alliance_credit WHERE alliance_id = ' #{alliance_id}' ORDER BY day ASC")

  query_members = ""
  query_daily_credit = ""
  query_total_credit = ""
  j = 0;
  size = result.count
  size_part = (size/10.0).ceil
  result.each do |row|
    print "#{j}/#{size} " if (j)%(size_part) == 0
    j += 1
    day = row['day'].to_i
    query_members << " #{day_to_timestamp(day)}:#{row['current_members'].to_i}"
    query_daily_credit << " #{day_to_timestamp(day)}:#{row['daily_credit'].to_i}"
    query_total_credit << " #{day_to_timestamp(day)}:#{row['total_credit'].to_i}"
  end
  print "creating files \n"
  path_to_storage = "/opt/graphite/storage/whisper/stats/gauges/TSN_dev/general/alliance/#{alliance_id}/"
  call_whisper(path_to_storage+'current_members.wsp',query_members)
  call_whisper(path_to_storage+'daily_credit.wsp',query_daily_credit)
  call_whisper(path_to_storage+'total_credit.wsp',query_total_credit)
end