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

  end
  desc "award trophies from file"
  task :trophies_csv => enviroment do
    trophy_id = nil
    trophy = Trophy.find trophy_id
    file = "./tmp/galaxy_7000.csv"
    csv =  CSV.parse(File.read(file), :headers => true)

    ids = csv.map {|i| i["id"].to_i}

    profiles = Profile.joins{general_stats_item.boinc_stats_item}.where{general_stats_item.boinc_stats_item.id.in ids}
    trophy.award_to_profiles(profiles)
  end
end
