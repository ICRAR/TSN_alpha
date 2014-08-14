namespace :update_profiles do
  desc "recent nereus users"
  task :recent_nereus_users => :environment do
    remote_sql = NereusStatsItem.connect_to_backend_db
    query = "SELECT distinct skynetID From dailyaccountusage where day > #{((Time.now.to_i)/86400).to_i-7} and skynetID > 0"
    ids_result = remote_sql.query query
    ids = ids_result.map{|r| r['skynetID'].to_i}
    csv = CSV.generate({}) do |csv|
      csv << ["theSkyNet User ID","First Name","Last Name","Email Address","Country", "theSkyNet Username"]
      profiles = Profile.includes(:user).joins{general_stats_item.nereus_stats_item}.where{general_stats_item.nereus_stats_item.nereus_id.in ids}
      profiles.find_in_batches(:batch_size => 1000) do |group|
        group.each do |p|
          if p.user.nil?
            puts p.to_yaml
          else
            csv << [p.id,p.first_name,p.second_name,p.user.email,p.country_name,p.user.username]
          end
        end
      end
    end
    file = Rails.root.join('tmp', 'profiles.csv')
    File.open(file, "w") { |file| file.write csv }
  end
  desc "reset trophies to 0"
  task :fix_trophies => :environment do

    print "\n Starting fix \n"
    stats = GeneralStatsItem.all
    stats.each do |item|
      print "profile = #{item.id} \n"
      item.last_trophy_credit_value = 0
      item.save
    end
  end
  desc "fix countries"
  task :fix_countries => :environment do
    #get all affected profiles
    profiles = Profile.where{length(country) > 2}
    countries = CountrySelect.const_get :COUNTRIES

    profiles.each do |p|
      new_name = countries.key(p.country.titleize)
      new_name = 'ru' if  p.country == "Russia"
      puts "#{p.country} : #{new_name}"
      unless new_name.nil?
        puts "change #{new_name}"
        p.country =  new_name
        p.save
      end
    end

  end
  desc "gives every user a nickname"
  task :fix_nicknames => :environment do

    print "\n Starting fix \n"
    profiles = Profile.all
    i = 1
    profiles.each do |p|
      print "profile = #{p.id} \n"
      p.nickname = p.user ? p.user.email : i unless p.nickname
      p.save
      i += 1
    end
  end
  desc "fix broken current alliance membership"
  task :fix_membership => :enviroment do
    AllianceMembers.where{(leave_date == nil) & (profile.alliance_id == nil)}.joins{profile}.each do |m|
      m.profile.alliance = m.alliance
      m.profile.save
    end
  end

  desc "fix alliance founded on dates"
  task :fix_alliance_founded => :enviroment do
    #connect to old front end db
    remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host_front_end'], :username => APP_CONFIG['nereus_username_front_end'], :database => APP_CONFIG['nereus_database_front_end'], :password => APP_CONFIG['nereus_password_front_end'])
    results = remote_client.query("SELECT * FROM `Team`", :cache_rows => false)
    results.each do |row|
      old_id = row['id'].to_i
      new_alliance = Alliance.where{(alliances.old_id == my{old_id})}.first
      unless new_alliance.nil?
        new_alliance.created_at = row['creationDate']
        new_alliance.save
      end
    end
  end

  desc "export emails to file"
  task :export_emails => :enviroment do
    profiles = Profile

    Benchmark.measure do
      csv = CSV.generate({}) do |csv|
        csv << ["theSkyNet User ID","First Name","Last Name","Email Address","Country", "theSkyNet Username"]
        profiles.includes(:user).find_in_batches(:batch_size => 1000) do |group|
          group.each do |p|
            if p.user.nil?
              puts p.to_yaml
            else
              csv << [p.id,p.first_name,p.second_name,p.user.email,p.country_name,p.user.username]
            end
          end
        end
      end
      file = Rails.root.join('tmp', 'profiles.csv')
      File.open(file, "w") { |file| file.write csv }
    end
    #scp -i ~/.ssh/icrar_theskynet_public_prod.pem ec2-user@tsn-prod:/home/ec2-user/tsn_test/current/tmp/profiles.csv ./profiles.csv

  end
  desc "award trophies from file"
  task :trophies_csv => :environment do
    trophy_id = nil
    trophy = Trophy.find trophy_id
    file = "./tmp/rac_today.csv"
    csv =  CSV.parse(File.read(file), :headers => true)

    ids = csv.map {|i| i["id"].to_i}

    profiles = Profile.where{id.in ids}

    extra = NereusStatsItem.founding_ids
    first = NereusStatsItem.founding_first
    last = NereusStatsItem.founding_last

    #Profile.joins{general_stats_item.nereus_stats_item}.where{((nereus_stats_items.nereus_id >= first) & (nereus_stats_items.nereus_id <= last)) | (nereus_stats_items.nereus_id.in extra)}
    trophy.award_to_profiles(profiles)
  end
  desc "award trophies for galaxy"
  task :trophies_csv => :environment do
    trophy_id = 191
    trophy = Trophy.find trophy_id
    galaxy_id = 17000

    galaxy = Galaxy.find galaxy_id
    profiles = galaxy.profiles
    trophy.award_to_profiles(profiles)
  end
  desc "award trophies for a galaxy area "
  task :trophies_csv => :environment do
    trophy_id = 184
    trophy = Trophy.find trophy_id
    galaxy_area_id = 8 * 1000 * 1000

    boinc_ids = GalaxyAreaUser.where{area_id == galaxy_area_id}.pluck(:userid)


    profiles = Profile.joins{general_stats_item.boinc_stats_item}.where{boinc_stats_items.boinc_id.in boinc_ids}
    trophy.award_to_profiles(profiles)
  end
  desc "change bonus credit desc"
  task :trophies_csv => :environment do
    old = "imported from old site"
    new = "Pre-T2 Bonus Credit (no reason stored, contact support if you have a question)"
    BonusCredit.where{reason == old}.update_all(:reason => new)

    old = "Fix for old site conversion"
    new = "T2 Conversion Hiccup (T2 credit didn't match old credit when we converted, shortfall in credit applied as a bonus)"
    BonusCredit.where{reason == old}.update_all(:reason => new)

    BonusCredit.where{amount <= 0}.delete_all
  end
  desc "change bonus credit desc"
  task :trophies_csv => :environment do
    alliance_ids = [588,762,535,539,570,542,665,537,551,557,571,751,613,719,802,834,759]
    profiles = Profile.joins{general_stats_item.boinc_stats_item}.
        where{alliance_id.in alliance_ids}.
        where{(general_stats_item.boinc_stats_item.challenge > 0) | ( general_stats_item.boinc_stats_item.save_value > 0) }; nil
  end
  desc "find leaders of dup alliance"
  task :trophies_csv => :environment do
    as = []
    Alliance.where{is_boinc == false}.each do |a|
      a2 = Alliance.where{name == "#{a.name} (POGS)"}.first
      unless a2.nil?
        info_hash = {
            name: a.name,
            old_id: a.id,
            new_id: a2.id,
            pogs_id: a2.pogs_team_id,
            old_leader: (a.leader.nil? ? '-' : a.leader.id),
            old_leader_name: (a.leader.nil? ? '-' : a.leader.name),
            old_leader_email: (a.leader.nil? ? '-' : a.leader.user.email),
            new_leader: (a2.leader.nil? ? '-' : a2.leader.id),
            new_leader_name: (a2.leader.nil? ? '-' : a2.leader.name),
            new_leader_email: (a2.leader.nil? ? '-' : a2.leader.user.email),
            flagged: !a2.duplicate_id.nil?,
            old_members: []
        }
        a.members.each do |p|
          info_hash[:old_members] << {
              name: p.name,
              email: p.user.email,
              boinc_id: (p.general_stats_item.boinc_stats_item.nil? ? 0 : p.general_stats_item.boinc_stats_item.boinc_id),
              credit: p.general_stats_item.total_credit,
              rac: p.general_stats_item.recent_avg_credit
            }
        end
        as << info_hash
      end
    end; nil

    sums = {}
    sums[:total_alliances] = as.count
    sums[:alliances_same_leader] = as.count{|a| a[:old_leader] == '-'}
    sums[:alliances_different_leader] = as.count{|a| a[:old_leader] != '-'}
    sums[:flagged] = as.count{|a| a[:flagged]}
    sums[:merge] = as.count{|a| (a[:old_leader] == '-') || a[:flagged]}
    sums[:same_leader_not_flagged] = as.count{|a| (a[:old_leader] == '-') && !a[:flagged]}
    sums[:total_members] = as.inject(0){|sum,a| sum + a[:old_members].count}
    sums[:total_members_boinc] = as.inject(0){|sum,a| sum + a[:old_members].count{|p| p[:boinc_id] != 0}}
    sums[:total_members_not_boinc] = as.inject(0){|sum,a| sum + a[:old_members].count{|p| p[:boinc_id] == 0}}
    conflicted_users = []
    conflicted_alliances = []
    sums[:total_members_not_boinc_in_merge] =  as.inject(0) do |sum,a|
      mem_count = a[:old_members].count{|p| p[:boinc_id] == 0}
      is_merge = ((a[:old_leader] == '-') || a[:flagged])
      conflic_count = is_merge ? mem_count : 0
      if is_merge
        a[:old_members].each do |p|
          conflicted_users << p if p[:boinc_id] == 0
        end
        conflicted_alliances << a
      end
      sum + conflic_count
    end
    leader_hash = {}
    leader_hash[:same_leaders_not_flagged] = []
    leader_hash[:same_leaders_are_flagged] = []
    leader_hash[:different_leaders_are_flagged]= []
    leader_hash[:different_leaders_not_flagged] = []
    as.each do |a|
      if a[:old_leader] == '-'
        if !a[:flagged]
          leader_hash[:same_leaders_not_flagged] << {
              leader_name: a[:new_leader_name],
              leader_email: a[:new_leader_email],
              leader_id: a[:new_leader],
              old_id: a[:old_id],
              new_id: a[:new_id],
              alliance_name: a[:name]
          }
        else
              leader_hash[:same_leaders_are_flagged] << {
              leader_name: a[:new_leader_name],
              leader_email: a[:new_leader_email],
              leader_id: a[:new_leader],
              old_id: a[:old_id],
              new_id: a[:new_id],
              alliance_name: a[:name]
          }
        end
      elsif a[:new_leader] == '-'
        if !a[:flagged]
          leader_hash[:same_leaders_not_flagged] << {
              leader_name: a[:old_leader_name],
              leader_email: a[:old_leader_email],
              leader_id: a[:old_leader],
              old_id: a[:old_id],
              new_id: a[:new_id],
              alliance_name: a[:name]
          }
        else
          leader_hash[:same_leaders_are_flagged] << {
              leader_name: a[:old_leader_name],
              leader_email: a[:old_leader_email],
              leader_id: a[:old_leader],
              old_id: a[:old_id],
              new_id: a[:new_id],
              alliance_name: a[:name]
          }
        end
      else
        if !a[:flagged]
          leader_hash[:different_leaders_not_flagged] << {
              leader_name: a[:new_leader_name],
              leader_email: a[:new_leader_email],
              leader_id: a[:new_leader],
              other_id: a[:old_id],
              their_id: a[:new_id],
              alliance_name: a[:name]
          }
          leader_hash[:different_leaders_not_flagged] << {
              leader_name: a[:old_leader_name],
              leader_email: a[:old_leader_email],
              leader_id: a[:old_leader],
              other_id: a[:new_id],
              their_id: a[:old_id],
              alliance_name: a[:name]
          }
        else
          leader_hash[:different_leaders_are_flagged] << {
              leader_name: a[:new_leader_name],
              leader_email: a[:new_leader_email],
              leader_id: a[:new_leader],
              other_id: a[:old_id],
              their_id: a[:new_id],
              new_id: a[:new_id],
              alliance_name: a[:name]
          }
          leader_hash[:different_leaders_are_flagged] << {
              leader_name: a[:old_leader_name],
              leader_email: a[:old_leader_email],
              leader_id: a[:old_leader],
              other_id: a[:new_id],
              their_id: a[:old_id],
              new_id: a[:new_id],
              alliance_name: a[:name]
          }
        end
      end
    end; nil

    leader_hash.each do |name, array_hash|
      puts name
      csv = CSV.generate({}) do |csv|
        csv << array_hash.first.keys
        array_hash.each do |h|
          csv << h.values
        end
      end
      puts csv
      puts '****************'
    end; nil

    as = Alliance.where{(length(name) > 0) & (credit == 0)}; nil
    csv = CSV.generate({}) do |csv|
      csv << [:id,:name]
      as.each do |a|
        csv << [a.id,a.name]
      end; nil
    end; nil
    puts csv
  end
  desc "migrate alliances"
  task :migrate_alliances => :environment do
    #load all alliances waiting to merge
    BoincJob.new.perform_without_schedule

    alliances = Alliance.where{(is_boinc == true) & (duplicate_id > 0)}
    alliances.each do |alliance|

      #load the second alliance
      second_alliance = Alliance.find alliance.duplicate_id
      #merge allainces
      alliance.merge_pogs_team second_alliance
      #fix duplicate id and invite_only
      alliance.duplicate_id = nil
      pogs_team = PogsTeam.find alliance.pogs_team_id
      alliance.invite_only = pogs_team.joinable == 1 ? false : true
      alliance.save
      #save and done

    end

    count = 0
    Alliance.where{(pogs_team_id > 0)}.each do |a|
      pogs_team = PogsTeam.where{id == a.pogs_team_id}.first

      unless pogs_team.nil?
        a.invite_only = pogs_team.joinable == 1 ? false : true
        a.name = pogs_team.name
        if a.valid?
          a.save
          count = count + 1
        else
          a.name = pogs_team.name + " (POGS)"
          a.save
          count = count + 1
        end
      end


    end; nil
    count

    Alliance.where{(duplicate_id > 0)}



    BoincJob.new.perform_without_schedule
    StatsAlliancesJob.new.perform_without_schedule

  end
  desc "find allainces for migrate alliances"
  task :find_alliances => :environment do
    Alliance.where{(is_boinc == true) & (duplicate_id == nil)}.each do |a|
      a2 = Alliance.where{name == a.name[0..-8]}.first
      unless a2.nil?
        if a.leader.nil? || a2.leader.nil?
          a2.mark_duplicate a.id
        end
      end
    end
  end
  desc "fix pogs nil leaders"
  task :fix_pogs_leaders => :environment do
    Alliance.where{(is_boinc == true)}.each do |a|
      if a.leader.nil?
        pogs_team = PogsTeam.find a.pogs_team_id
        b = BoincStatsItem.find_by_boinc_id pogs_team.userid
        p = b.general_stats_item.profile
        a.leader = p
      end
    end
  end
  desc "fix pogs nil leaders"
  task :trophy_thing => :environment do
    us = []
    ids = CSV.read("../../tmp/herschel2.csv").map {|i| i.first.to_i}
    CSV.foreach("../../tmp/herschel.csv", {col_sep: ';', encoding: 'iso-8859-1'}) do |r|
      row = {}
      name_value = r.first
      row["name"] = r.first
      row["rank"] = r[2]

      count = BoincRemoteUser.where{name == my{name_value}}.count
      row["boinc_count"] = count

      if count == 0
        #we can't find him, try a wider search
        #come back to this if need be
        row["boinc_id"] = nil
        row["no_name"] = true
      elsif count == 1
        #we found him
        row["boinc_id"] = BoincRemoteUser.where{name == my{name_value}}.first.try :id
      else
        #try to narrow by team name
        #look for team
        row["trying_team"] = true
        team_name = r[1]
        team_count = PogsTeam.where{name == my{team_name}}.count
        row["team_count"] = team_count
        if team_count == 1

          team_id = PogsTeam.where{name == my{team_name}}.first.try(:id)
          count = BoincRemoteUser.where{(name == my{name_value}) & (teamid == my{team_id})}.count
          if count == 1
            row["boinc_id"] = BoincRemoteUser.where{(name == my{name_value}) & (teamid == my{team_id})}.first.try(:id)
          elsif count == 0
            row["not_in_team"] = true
            row["boinc_id"] = nil
          else
            row["to_many_in_team"] = true
            # try to narrow down by credit
            min_credit  = r[3].tr(',', '').to_i
            count = BoincRemoteUser.where{(name == my{name_value}) & (teamid == my{team_id}) & (total_credit > my{min_credit})}.count
              if count == 1
                row["boinc_id"] = BoincRemoteUser.where{(name == my{name_value}) & (teamid == my{team_id}) & (total_credit > my{min_credit})}.first.try(:id)
              else
                row["to_many_with_cedit"] = true
                row["boinc_id"] = nil
              end
            row["boinc_id"] = nil
          end
        else
          #can't find a team :(
          row["boinc_id"] = nil
        end
      end
      us << row
    end; nil

    us.each do |u|
      puts u.to_yaml if u["boinc_id"].nil?
    end; nil

    CSV.foreach("../../tmp/herschel.csv", {col_sep: ';', encoding: 'iso-8859-1'}){|r| puts r[3].tr(',', '').to_i}
  end
  desc "fix pogs nil leaders"
  task :ghost_users => :environment do
    g = GeneralStatsItem.joins{nereus_stats_item.outer}.joins{boinc_stats_item.outer}.
      where{(boinc_stats_item.general_stats_item_id == nil) & (nereus_stats_item.general_stats_item_id == nil)}.
      joins{profile}.where{profile.alliance_id != nil};

    g.each do |p|
      profile = p.profile
      item = profile.alliance_items.where{(leave_date == nil) & (alliance_id == my{profile.alliance_id})}.first
      item.leave_alliance_without_notification(profile) unless item.nil?
      profile.alliance = nil
      profile.save
    end; nil

  end

  desc "copy BOINC profiles"
  task :copy_boinc_profiles => :environment do
    BoincProfile.all.each do |bp|
      boinc_item = BoincStatsItem.find_by_boinc_id bp.userid
      unless boinc_item.nil?
        profile =  boinc_item.general_stats_item_id.nil? ? nil : boinc_item.general_stats_item.profile
        unless profile.nil?
          puts profile.name
          puts bp.description.gsub('[%between%]', '')
          if profile.description.nil? || profile.description == ''
            profile.description = bp.description.gsub('[%between%]', '')
            profile.save
          end
        end
      end
    end; nil

  end
  desc "Boinc Pentathlong user"
  task :penthalon_2014 => :environment do
    team_ids = [1502,38,1140,6,175,19,1845,55,32,1600,58,1,8,1687,2082,270,1058,266,17,16,20,40,24,1648,45,29,110,54,9,50]
    teams = PogsTeam.where{id.in team_ids}
    user_ids = BoincRemoteUser.where{(teamid.in team_ids) & (expavg_time > 15.days.ago.to_i)}.pluck(:id)

    user_ids = [1, 3, 8, 40, 2938, 3121, 3501, 3646, 3980, 6352, 7960, 8031, 8051, 8078, 8434, 8535, 9200, 9237, 9864, 10362, 12121, 12237, 13133, 13352, 15596, 20054, 26, 100, 124, 125, 129, 135, 136, 157, 164, 190, 263, 1931, 1941, 1958, 1970, 1975, 2019, 2047, 2065, 2066, 2068, 2069, 2071, 2079, 2080, 2089, 2091, 2093, 2094, 2096, 2097, 2098, 2134, 2207, 2226, 2267, 2272, 2278, 2280, 2306, 2321, 2485, 2487, 2498, 2528, 2604, 2646, 2662, 2696, 2706, 2731, 2732, 2738, 2740, 2741, 2744, 2745, 2747, 2748, 2749, 2750, 2751, 2754, 2758, 2764, 2765, 2770, 2773, 2776, 2777, 2785, 2786, 2792, 2796, 2797, 2799, 2801, 2802, 2818, 2840, 2844, 2855, 2924, 3109, 3207, 3271, 3385, 3468, 3596, 3613, 3699, 3724, 3915, 3987, 3990, 3994, 4013, 4159, 5739, 5950, 6128, 6590, 6602, 6605, 6607, 6608, 6611, 6614, 6626, 6628, 6631, 6633, 6635, 6645, 6656, 6658, 6663, 6670, 6677, 6696, 6697, 6706, 6742, 6774, 6791, 6829, 6879, 6896, 7025, 7069, 7975, 7980, 7981, 8094, 8259, 8585, 8875, 9212, 9681, 10695, 10725, 10929, 11081, 11337, 11388, 12434, 12457, 12505, 12731, 13253, 13338, 13924, 13967, 14500, 14522, 14526, 14530, 14538, 14542, 14544, 14549, 14557, 14574, 14584, 14589, 14643, 14723, 14800, 14844, 14968, 15055, 15181, 15471, 15946, 15947, 15948, 15985, 16675, 22124, 23301, 23406, 25, 27, 29, 32, 34, 38, 45, 51, 91, 101, 114, 123, 137, 173, 179, 294, 326, 341, 2017, 2036, 2162, 2164, 2176, 2196, 2247, 2261, 2298, 2312, 2365, 2385, 2479, 2512, 2530, 2789, 2820, 2899, 2981, 2993, 2996, 3067, 3126, 3328, 3362, 3719, 3763, 3797, 3896, 3942, 4053, 4070, 4123, 4139, 4177, 4212, 4233, 4242, 5243, 5256, 6306, 6761, 6831, 7083, 7084, 7089, 7091, 7093, 7098, 7115, 7116, 7142, 7161, 7174, 7221, 7230, 7266, 7279, 7295, 7311, 7318, 7321, 7383, 7399, 7405, 7407, 7408, 7409, 7411, 7416, 7417, 7420, 7421, 7428, 7435, 7438, 7441, 7442, 7444, 7445, 7447, 7448, 7456, 7457, 7470, 7476, 7477, 7483, 7485, 7487, 7490, 7493, 7496, 7497, 7498, 7499, 7510, 7516, 7517, 7527, 7529, 7531, 7537, 7539, 7541, 7546, 7550, 7553, 7554, 7558, 7563, 7565, 7568, 7569, 7570, 7571, 7580, 7581, 7583, 7589, 7591, 7592, 7594, 7596, 7597, 7598, 7602, 7609, 7614, 7627, 7628, 7635, 7636, 7641, 7644, 7645, 7647, 7648, 7653, 7666, 7672, 7676, 7678, 7682, 7683, 7689, 7692, 7693, 7700, 7701, 7707, 7712, 7717, 7728, 7732, 7736, 7739, 7749, 7752, 7754, 7771, 7780, 7808, 7835, 7841, 7842, 7853, 7859, 7881, 7886, 7887, 7900, 7918, 7930, 7947, 8018, 8183, 8209, 8384, 8386, 8390, 8459, 8465, 8512, 8598, 8640, 8748, 9054, 9071, 9269, 9462, 9714, 10066, 10284, 10307, 10609, 11880, 11941, 11947, 12043, 12417, 12484, 12616, 12627, 12630, 12653, 12681, 12771, 12795, 13526, 13715, 13745, 14508, 14511, 14814, 14977, 15047, 15121, 15235, 15838, 16071, 16133, 18362, 21557, 21621, 21662, 21700, 21725, 21883, 21924, 21937, 22194, 22567, 22584, 22593, 22594, 22610, 22618, 22622, 22628, 22636, 22639, 22640, 22641, 22645, 22649, 22656, 22657, 22659, 22663, 22664, 22666, 22669, 22671, 22672, 22674, 22676, 22678, 22680, 22685, 22687, 22692, 22699, 22702, 22703, 22704, 22707, 22711, 22714, 22720, 22800, 22830, 22834, 22913, 22915, 22948, 22955, 22970, 22975, 22978, 22980, 22995, 23269, 23393, 23404, 23478, 23527, 39, 115, 2127, 2221, 2257, 2548, 2560, 2795, 2806, 2892, 2926, 3419, 3442, 4124, 4352, 4556, 4754, 4845, 6384, 8170, 8833, 9210, 9316, 10434, 10638, 11052, 11215, 11716, 12210, 12274, 14798, 15073, 20477, 21079, 21521, 21633, 21636, 22163, 22378, 22389, 22390, 22391, 22392, 22400, 22416, 22417, 22424, 22551, 22786, 22991, 23343, 23348, 23422, 23427, 23455, 23458, 23469, 23476, 23510, 42, 48, 57, 59, 62, 66, 72, 76, 78, 84, 93, 97, 99, 105, 131, 162, 196, 206, 230, 1397, 1817, 1934, 1937, 1952, 2042, 2055, 2118, 2165, 2276, 2402, 2405, 2426, 2427, 2430, 2436, 2438, 2440, 2441, 2442, 2447, 2469, 2639, 2710, 3024, 3074, 3080, 3088, 3319, 3477, 3512, 3677, 3875, 3891, 3949, 3957, 4029, 4257, 4280, 4349, 6274, 6476, 6572, 7277, 7705, 8221, 8553, 8978, 9032, 9034, 9097, 9150, 9190, 9209, 9225, 9227, 9241, 9246, 9251, 9255, 9258, 9265, 9267, 9274, 9276, 9286, 9299, 9318, 9349, 9405, 9448, 9527, 9595, 9645, 9830, 9831, 9911, 9948, 9996, 10115, 10127, 10168, 10265, 10287, 10327, 10741, 10760, 11209, 11772, 12307, 12377, 12430, 12449, 12897, 13339, 13558, 13701, 13836, 14187, 14189, 14194, 14263, 14349, 14384, 14497, 14787, 14811, 15156, 15190, 15295, 15316, 15343, 15643, 16029, 16424, 17682, 19358, 20310, 20637, 21444, 21485, 21512, 21564, 21627, 21631, 21673, 21698, 21705, 21729, 21776, 21778, 21785, 21819, 21835, 21836, 21841, 21866, 21871, 21894, 21923, 21927, 21982, 22001, 22005, 22019, 22041, 22046, 22047, 22059, 22070, 22071, 22130, 22153, 22157, 22180, 22196, 22225, 22253, 22258, 22261, 22338, 22364, 22370, 22381, 22382, 22405, 22517, 22681, 22683, 22686, 22924, 22972, 23014, 23268, 23335, 23519, 23529, 61, 109, 281, 283, 285, 2053, 2119, 2183, 2489, 2887, 3371, 3652, 3923, 3960, 4198, 4210, 5069, 5403, 5629, 5875, 6309, 6638, 6797, 7291, 7998, 8308, 8687, 9752, 10203, 10522, 10713, 12396, 12510, 12683, 12807, 12886, 13552, 14142, 15519, 20475, 21768, 21771, 21773, 21775, 21777, 21782, 21784, 21786, 21789, 21792, 21793, 21803, 21822, 21827, 21865, 21893, 21926, 21929, 21933, 21955, 21962, 22031, 22062, 22075, 22076, 22085, 22167, 22203, 22265, 22439, 22525, 22526, 22527, 22544, 22550, 22552, 22554, 22556, 22563, 22793, 22845, 22916, 22932, 22945, 22953, 22973, 22974, 23368, 23383, 23473, 23487, 79, 82, 160, 169, 175, 201, 255, 1940, 1962, 2058, 2192, 2357, 2558, 2580, 3002, 3333, 3828, 3941, 3962, 6423, 7097, 10709, 11609, 14020, 16448, 21070, 21509, 21735, 64, 90, 95, 103, 107, 108, 112, 120, 155, 393, 1417, 1983, 1984, 1993, 2032, 2048, 2136, 2456, 2463, 2503, 2629, 2652, 2865, 3150, 3346, 3357, 3567, 3936, 4170, 5856, 5881, 6153, 6543, 6765, 6772, 7663, 8718, 8783, 8816, 8884, 9625, 9723, 9730, 9759, 9844, 9870, 9884, 9930, 9993, 10039, 10086, 10415, 10423, 10801, 11552, 11637, 12203, 12328, 12932, 12949, 13228, 13325, 13591, 13621, 13678, 13710, 13725, 13909, 13958, 14063, 14064, 14073, 14081, 14087, 14095, 14105, 14111, 14125, 14127, 14134, 14152, 14153, 14171, 14174, 14178, 14206, 14208, 14310, 14311, 14375, 14401, 14602, 14664, 14780, 14888, 15247, 15688, 15727, 16023, 19911, 21648, 21889, 21909, 21912, 22259, 23145, 23201, 23402, 23530, 126, 1936, 2012, 2570, 2814, 2856, 3976, 5288, 5556, 6220, 6473, 6528, 6630, 6814, 6940, 7000, 7220, 7579, 7643, 7673, 7772, 7902, 8019, 8389, 8448, 8631, 8668, 8729, 8926, 8949, 9124, 9178, 9198, 9234, 9259, 9441, 9455, 9725, 9913, 10014, 10096, 10134, 10296, 10351, 10444, 10547, 10577, 10722, 10768, 10862, 10884, 10950, 11091, 11158, 11182, 11210, 11221, 11300, 11326, 11367, 11468, 11525, 11573, 11624, 11869, 11909, 11980, 12103, 12127, 12248, 12359, 12433, 12528, 12539, 12617, 12666, 12809, 12817, 12839, 12876, 12909, 12978, 12986, 12993, 13121, 13135, 13142, 13157, 13167, 13295, 13501, 13547, 13548, 13674, 13689, 13705, 13763, 13781, 13782, 13803, 13838, 13858, 13870, 13897, 13976, 14044, 14130, 14135, 14137, 14177, 14249, 14302, 14304, 14342, 14350, 14360, 14399, 14474, 14498, 14607, 14653, 14665, 14679, 14703, 14725, 14833, 14845, 14851, 14911, 14933, 14942, 14987, 15006, 15016, 15024, 15034, 15035, 15044, 15133, 15150, 15159, 15171, 15188, 15207, 15264, 15265, 15312, 15321, 15641, 15652, 15655, 15724, 21121, 21905, 21906, 21916, 22474, 22483, 22541, 22990, 146, 16363, 183, 274, 311, 316, 331, 1919, 2027, 2106, 2152, 2154, 2159, 2161, 2175, 2178, 2186, 2189, 2212, 2281, 2341, 2356, 2377, 2383, 2384, 2419, 2488, 2694, 2942, 3011, 3401, 3402, 3443, 3474, 3820, 4760, 5422, 6016, 6363, 7750, 7762, 7814, 7843, 8143, 8831, 9065, 9474, 9530, 9593, 9842, 10050, 10063, 10503, 10837, 11755, 12009, 12271, 12636, 12777, 12958, 13124, 13288, 14291, 14696, 21490, 21517, 21534, 21547, 21580, 21603, 21612, 21614, 21665, 21666, 21731, 21756, 21846, 21853, 21858, 21880, 21941, 21972, 21986, 22008, 22012, 22013, 22023, 22026, 22040, 22058, 22061, 22063, 22064, 22066, 22074, 22156, 22168, 22207, 22213, 22230, 22245, 22269, 22361, 22363, 22428, 22438, 22943, 23470, 23477, 1968, 1972, 2476, 2608, 2974, 3609, 3694, 4398, 6261, 13303, 13766, 21677, 21838, 23492, 216, 2421, 236, 238, 242, 245, 249, 280, 302, 2545, 6775, 7302, 14671, 19413, 21644, 21667, 21973, 22240, 22447, 23395, 23532, 11415, 282, 288, 1942, 8815, 14514, 14776, 14806, 14871, 15331, 16222, 21702, 22082, 22166, 22217, 22260, 267, 289, 2111, 2686, 3597, 4045, 4065, 4081, 7906, 8225, 8561, 8906, 9812, 9966, 10164, 10750, 11365, 11532, 12504, 13159, 13660, 14509, 15452, 16269, 19349, 22519, 313, 2408, 2627, 6129, 13222, 21446, 21454, 21535, 21536, 21571, 21594, 21607, 21640, 21684, 21686, 21689, 21708, 21763, 21798, 21799, 21807, 21829, 21837, 21854, 21862, 21864, 21872, 21873, 21931, 21947, 21984, 22004, 22010, 22016, 22067, 22069, 22221, 22247, 22266, 22267, 22402, 22411, 22415, 22421, 22433, 22478, 22549, 22566, 22677, 22838, 22925, 22927, 22938, 22993, 23083, 23122, 23131, 23132, 23134, 23238, 23251, 23259, 23413, 23475, 23479, 23482, 23495, 23501, 23511, 23515, 1985, 2462, 2723, 3026, 3603, 3874, 3968, 3991, 6513, 6863, 7133, 9434, 9480, 9573, 9675, 9743, 9931, 9992, 10213, 10515, 10572, 10632, 10791, 10986, 10992, 11303, 11757, 11884, 11889, 11975, 12015, 12145, 12414, 12674, 12746, 13349, 13533, 13583, 14539, 15011, 17760, 18475, 18765, 21466, 21468, 21469, 21473, 21477, 21478, 21541, 21549, 21574, 21582, 21590, 21625, 21669, 21699, 21701, 21704, 21710, 21713, 21750, 21764, 21820, 21824, 21833, 21849, 21859, 21901, 21914, 21918, 21928, 21934, 21938, 21940, 21958, 21983, 21999, 22000, 22083, 22102, 22274, 22409, 22412, 22604, 22629, 23149, 23340, 23534, 209, 21452, 21646, 21800, 21844, 22090, 65, 330, 544, 3044, 3056, 3057, 3058, 3063, 3099, 3494, 3612, 3615, 3616, 3618, 3621, 3624, 3626, 3630, 3635, 3636, 3639, 3641, 3648, 3649, 3650, 3654, 3672, 3738, 3836, 3898, 4091, 4311, 6267, 8082, 9393, 9932, 14333, 21447, 21449, 21482, 21508, 21510, 21515, 21516, 21530, 21542, 21550, 21553, 21555, 21558, 21565, 21566, 21573, 21584, 21589, 21602, 21610, 21617, 21619, 21634, 21635, 21651, 21653, 21656, 21657, 21659, 21660, 21671, 21672, 21674, 21675, 21680, 21690, 21695, 21706, 21709, 21714, 21715, 21716, 21722, 21724, 21727, 21728, 21730, 21733, 21734, 21743, 21753, 21788, 21821, 21834, 21840, 21888, 21942, 21988, 22002, 22011, 22030, 22038, 22114, 22170, 22175, 22185, 22206, 22208, 22214, 22216, 22219, 22223, 22242, 22243, 22244, 22264, 22437, 22520, 22542, 22570, 22679, 22849, 22907, 22928, 22934, 23126, 23198, 23346, 23378, 23381, 23391, 23419, 23426, 23431, 23437, 23439, 23442, 23443, 23444, 23446, 23447, 23456, 23488, 548, 914, 2123, 2174, 2283, 2285, 2534, 2535, 2552, 2872, 3538, 6076, 6923, 7040, 8982, 10341, 10887, 11399, 11602, 12077, 12549, 12677, 13377, 13431, 13659, 14832, 14889, 20619, 21080, 21089, 21484, 21518, 21604, 21618, 21745, 21801, 21808, 21809, 21870, 21907, 21913, 21957, 21976, 21985, 21987, 22056, 22079, 22081, 22184, 22224, 22235, 22239, 22241, 22289, 22302, 22312, 22782, 23403, 49, 2003, 2242, 2329, 2392, 2396, 2397, 2399, 2403, 2452, 2465, 2471, 2499, 2574, 2677, 2911, 2955, 2982, 3084, 3145, 3160, 3393, 3465, 3573, 3779, 4136, 4148, 4162, 4226, 4279, 4325, 5581, 5663, 6308, 6680, 6789, 6837, 6941, 7967, 8414, 10199, 11153, 11287, 11419, 11629, 12262, 12592, 12737, 12974, 13017, 13035, 13036, 13252, 13340, 13342, 13405, 13475, 13476, 13477, 13478, 13480, 13481, 13482, 13483, 13484, 13485, 13487, 13488, 13492, 13497, 13500, 13502, 13503, 13507, 13509, 13510, 13515, 13516, 13523, 13524, 13538, 13555, 13561, 13571, 13572, 13588, 13597, 13598, 13602, 13604, 13623, 13632, 13633, 13638, 13645, 13666, 13676, 13703, 13727, 13778, 13794, 13827, 13896, 13926, 13977, 13995, 14021, 14029, 14067, 14109, 14133, 14146, 14147, 14160, 14278, 14313, 14457, 14536, 14658, 14732, 15191, 15802, 15813, 21238, 21406, 21563, 21567, 21642, 21650, 21681, 21718, 21739, 21742, 21760, 21781, 21868, 21952, 22015, 22232, 23010, 23247, 23255, 1777, 2372, 12047, 21501, 21506, 21628, 21652, 21895, 310, 437, 1875, 2271, 2583, 3119, 3122, 4042, 8470, 8658, 8821, 10267, 10697, 21723, 22189, 22249, 22262, 22296, 22406, 22442, 22623, 23387, 1999, 2087, 2423, 2951, 5423, 5576, 8420, 8931, 11619, 11737, 12110, 14600, 15082, 21488, 21497, 21531, 21593, 21598, 21616, 21903, 21922, 21932, 21953, 22072, 22152, 22408, 22538, 22721, 22747, 22966, 22987, 23071, 23244, 2328, 3848, 3861, 4122, 21668, 2502, 3036, 3548, 3858, 9843, 10002, 12257, 16536, 16696, 19672, 21065, 21500, 21507, 21513, 21687, 21747, 21861, 21887, 21950, 21979, 22587, 22964, 23008, 3325, 13499, 13563, 13637, 15154, 16074, 18503, 20607, 21519, 21525, 21540, 21546, 21577, 21623, 21721, 21751, 21951, 22025, 22212, 22257, 22332, 22413, 22536, 22557, 22560, 22724]


  end
end
