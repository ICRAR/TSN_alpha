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
      puts bp.description
    end; nil

  end
end
