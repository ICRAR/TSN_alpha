namespace :update_profiles do

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
    Benchmark.measure do
      csv = CSV.generate({}) do |csv|
        csv << ["theSkyNet User ID","First Name","Last Name","Email Address","Country", "theSkyNet Username"]
        Profile.includes(:user).find_in_batches(:batch_size => 1000) do |group|
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
    trophy_id = 129
    trophy = Trophy.find trophy_id
    galaxy_id = 10000

    db_ids = Galaxy.connection.execute("select distinct au.userid
                from area_user au, area a
                where au.area_id = a.area_id
                and a.galaxy_id = #{galaxy_id};
                ")
    boinc_ids = db_ids.map {|i| i[0].to_i}

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
  end
end
