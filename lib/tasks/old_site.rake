namespace :old_site do

  desc "loads data from external site"
  task :load => :environment do
    #requries the user to set run_check=true at runtime to stop accidental running
    return false unless ENV['run_check'] == 'true'

    #connect to old front end db
    remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host_front_end'], :username => APP_CONFIG['nereus_username_front_end'], :database => APP_CONFIG['nereus_database_front_end'], :password => APP_CONFIG['nereus_password_front_end'])

    @power_users = [105208, 105211, 105212, 105213, 105580, 105579]


    #********* update nereus objects first ***************
    print "updating all nereus_stats_items \n"
    NereusJob.new.perform_without_schedule
    print "nereus items update complete \n"

    #*********add users************
    #load accounts
    print "starting user migration \n"
    print "fetching accounts \n"
    results = remote_client.query("SELECT `Account`.*, t1.first_day FROM `Account`
                                      LEFT JOIN (SELECT userID, MIN(`day`) as first_day FROM `dailyCredits` GROUP BY  userID) t1
                                      ON   `Account`.`userID` = t1.`userID`
                                      WHERE  `Account`.`userID` >= 10000 AND `Account`.`userID` <= 999999 ",
                                  :cache_rows => false)
    print "found #{results.count} accounts \n"
    #iterate across results and update local data
    print "starting user import \n"
    i = 0
    users_imported = 0
    results.each do |row|
      print "importing users #{i} to #{i+10} \n" if i%10 == 0
      old_user = generate_old_user(row)
      new_user = make_user(old_user)
      print "failed to import: #{old_user[:nereus_id]} **************************** #{new_user.errors.full_messages}\n" unless new_user.errors.empty?
      users_imported += 1 if new_user.errors.empty?
      i += 1
    end
    print "finished user import, we imported #{users_imported} new users\n"
    #************ add bonus credit to all users ****************

    update_bonus_credit(remote_client)
    fix_credit_with_bonus(remote_client)

    #************update users******************
    print "updating credit for all users \n"
    Rake::Task["stats:update_general"].execute
    print "credit updated \n"

    #***********Connect boinc users*******************
    Rake::Task["boinc:update_boinc"].execute
    connect_boinc_users

    #************import alliances *****************
    Alliance.delete_all
    AllianceMembers.delete_all
    print " starting alliance migration \n"
    print "fetching alliances \n"
    results = remote_client.query("SELECT * FROM `Team`", :cache_rows => false)
    print "found #{results.count} alliances \n"
    #iterate across results and update local data
    print "starting alliance import \n"
    i = 0
    alliances_imported = 0
    results.each do |row|
      print "importing alliances #{i} to #{i+10} \n" if i%10 == 0
      old_alliance = generate_old_alliance(row)
      new_alliance = make_alliance(old_alliance)

      #******************add all members******************
      print "-- fetching members"
      sub_results = remote_client.query( "SELECT T.*,
                        (
                          SELECT SUM(`credits`) as credit
                          FROM  `dailyCredits` WHERE  `dailyCredits`.`userID` = T.`userID`
                            AND  `dailyCredits`.`day` < (UNIX_TIMESTAMP(T.`joinTime`)/86400)
                        ) as start_credit,
                        (
                          SELECT SUM(`credits`) as credit
                          FROM  `dailyCredits` WHERE  `dailyCredits`.`userID` = T.`userID`
                            AND  `dailyCredits`.`day` < (
                              IFNULL(
                                UNIX_TIMESTAMP(T.`leaveTime`),UNIX_TIMESTAMP()
                              )/86400
                            )
                        ) as end_credit
                        FROM `TeamList` T
                        WHERE  `userID` >= 100000 AND `userID` <= 900000 AND T.`teamID` = #{old_alliance[:team_id]}",
                        :cache_rows => false)
      print "-- found #{sub_results.count} alliance members \n"
      #iterate across results and update local data
      print "-- starting alliance members import \n"
      j = 0
      alliance_members_imported = 0
      sub_results.each do |sub_row|
        print "-- importing alliances members #{j} to #{j+10} \n" if j%10 == 0
        old_member = generate_old_alliance_member(sub_row)
        new_member = add_member_to_alliance(new_alliance,old_member)
        print "-- failed to import: #{old_member[:nereus_id]} **************************** #{new_member.errors.full_messages}\n" unless new_member.errors.empty?
        alliance_members_imported += 1 if new_member.errors.empty?
        j += 1
      end
      print "-- finished alliance member import, we imported #{alliance_members_imported} new alliances members\n"

      print "failed to import: #{old_alliance[:team_id]} **************************** #{new_alliance.errors.full_messages}\n" unless new_alliance.errors.empty?
      alliances_imported += 1 if new_alliance.errors.empty?
      i += 1





    end
    print "finished alliance import, we imported #{alliances_imported} new alliances\n"

    #************update stats trophies ranks ect ***************
    Rake::Task["stats:update_alliances"].execute

    print "inserting trophies"
    create_trophies(remote_client)
    Rake::Task["stats:update_trophy"].execute


  end
end
=begin
  All this data is loaded from the old database
    old_user:
      nereus_id
      username
      email
      password : is a hash the can be made with Digest::SHA256.hexdigest(salt+Digest::SHA256.hexdigest(password))
      salt
      first_name
      last_name
      country
      network_limit
      paused
    eg
    old_user = {
        :nereus_id    =>      101032,
        :username     =>     'eckley_test',
        :email        =>     'eckley_test@gmail.com',
        :password     =>     Digest::SHA256.hexdigest('950993b'+Digest::SHA256.hexdigest('password')),
        :salt         =>     '950993b',
        :first_name   =>     'Alex_test',
        :last_name    =>'Tester',
        :country      =>'AU',
        :network_limit=>  10000000,
        :paused       =>  0
    }
=end
#takes approx .15s per user on my laptop so for a full db of 6000 users this will be slow
# but we only need to do this once
#make user takes the old user data and creates all the required models in the new websites database
#including connect to the corresponding nereus_stats_item
#note that it wont overwrite existing users
def make_user(old_user)
  #create user object
  return if User.find_by_email old_user[:email]
  new_user = User.new(
      :email => old_user[:email],
      :username => old_user[:username],
      :password => 'password',
      :password_confirmation => 'password',
  )

  new_user.skip_confirmation!
  new_user.confirmed_at = Time.parse('01/01/2013')
  if new_user.save
    #populate User field
    new_user.confirmed_at = old_user[:first_day]
    new_user.encrypted_password = old_user[:password]
    new_user.old_site_password_salt = old_user[:salt]
    new_user.admin = true if old_user[:username] == 'Eckley'  # hack to to auto generate myself as admin
    new_user.save
    #populate Profile Fields
    profile = new_user.profile
    profile.first_name = old_user[:first_name]
    profile.second_name = old_user[:last_name]
    profile.nickname = old_user[:username]
    profile.use_full_name = false
    profile.country = old_user[:country]
    profile.save

    #connect to nereus object
    nereus = NereusStatsItem.where(:nereus_id => old_user[:nereus_id]).try(:first)
    if nereus != nil
      profile.general_stats_item.nereus_stats_item = nereus
      profile.save
    else
      nereus = NereusStatsItem.new(
          :credit => 0,
          :daily_credit => 0,
          :nereus_id => old_user[:nereus_id],
          :rank => 0,
          :network_limit => 0,
          :monthly_network_usage => 0,
          :paused => 0,
          :active => 1,
          :online_today => 0,
          :online_now => 0,
          :mips_now => 0,
          :mips_today => 0,
          :last_checked_time => Time.now
      )
      nereus.save
      profile.general_stats_item.nereus_stats_item = nereus
      profile.general_stats_item.power_user = true if @power_users.include?(old_user[:nereus_id])
      profile.general_stats_item.save
      profile.save
    end
    #update nereus object
    nereus.network_limit = old_user[:network_limit]
    nereus.paused = old_user[:paused]

    return new_user
  else
    return new_user
  end

end

#takes the mysql row from old database Account table and populates a old_user item
def generate_old_user(row)
  old_user = {
      :nereus_id    => row['userID'].to_i,
      :username     => row['username'],
      :email        => row['email'],
      :password     => row['password'],
      :salt         => row['salt'],
      :first_name   => row['firstName'],
      :last_name    => row['lastName'],
      :country      => row['country'],
      :network_limit=> row['networkLimit'].to_i*1024*1024,
      :paused       => row['paused'].to_i == 1 ? true: false,
      :first_day    => row['first_day'] == nil ? Time.now.utc : Time.at(row['first_day']*86400).utc,
  }
end
=begin
  All this data is loaded from the old database
  leader_id: nereus_id  for leader
  name:
  desc: description
  tags:
  country:
  team_id: id from old db
  eg
  old_user = {
      :leader_id    =>      101032,
      :name     =>     'Curtin University of Technology',
      :country      =>'AU',
      :desc=>  'Invite only alliance.',
      :tags       =>  'curtin,university,bentley'
      :team_id =>  9
  }
=end
#make_alliance takes the old alliance data and creates all the required models in the new websites database
#note that it wont overwrite existing alliances   it will create duplicates
def make_alliance(old_alliance)
  #create user object
  new_alliance = Alliance.new(
      :name       => old_alliance[:name],
      :desc       => old_alliance[:desc],
      :tag_list       => old_alliance[:tags],
      :country    => old_alliance[:country],
      :old_id     => old_alliance[:team_id],
      :invite_only     => old_alliance[:invite_only]
  )
  if new_alliance.save
    #****** add leader.id
    new_alliance.leader = get_profile_by_nereus_id(old_alliance[:leader_id])
    new_alliance.created_at = old_alliance[:created_on]
    new_alliance.save
    new_alliance.errors.add(:leader, "Problem with leader maybe they don't exist") if new_alliance.leader == nil
    return new_alliance
  else
    return new_alliance
  end

end

#takes the mysql row from old database Account table and populates a old_user item
def generate_old_alliance(row)
  old_alliance = {
      :leader_id  => row['leaderID'].to_i,
      :name       => row['name'].to_s,
      :desc       => row['description'].to_s,
      :tags       => row['tags'].to_s,
      :country    => row['country'].to_s,
      :team_id    => row['id'].to_i,
      :created_on => row['creationDate'],
      :invite_only => row['type'].to_i.zero?
  }
end
def get_profile_by_nereus_id(nereus_id)
  n = NereusStatsItem.where(:nereus_id => nereus_id).first
  if n != nil && n.general_stats_item != nil
    n.general_stats_item.profile
  else
    nil
  end
end

=begin
  All this data is loaded from the old database
  nereus_id:  for member
  joinTime
  leaveTime
  start_credit
  end_credit
  eg
  old_user = {
      :nereus_id    =>      100005,
      :joinTime     =>     '2011-09-01 00:00:00	',
      :leaveTime      =>'NULL',
      :start_credit=>  'NULL',
      :end_credit       =>  '506364'
  }
credits are adjusted for conversion to new system so allaince will have the corrected credit values
=end
def generate_old_alliance_member(row)
  old_member = {
      :nereus_id    => row['userID'].to_i,
      :joinTime     => row['joinTime'] != nil ? row['joinTime'].to_s : nil,
      :leaveTime    => row['leaveTime'] != nil ? row['leaveTime'].to_s : nil,
      :start_credit => row['start_credit'] != nil ? row['start_credit'].to_i * APP_CONFIG['nereus_to_credit_conversion'] : 0,
      :end_credit   => row['end_credit'] != nil ? row['end_credit'].to_i * APP_CONFIG['nereus_to_credit_conversion']: 0,
  }
end
def add_member_to_alliance(new_alliance,old_member)
  profile = get_profile_by_nereus_id(old_member[:nereus_id])
  if profile  != nil
    profile.alliance = new_alliance if old_member[:leaveTime] == nil
    item = AllianceMembers.new
    item.join_date = old_member[:joinTime]
    item.start_credit = old_member[:start_credit]
    item.leave_credit = old_member[:end_credit]
    item.leave_date = old_member[:leaveTime]

    profile.alliance_items << item
    new_alliance.member_items << item

    item.save
    profile.save
    profile
  else
    profile = Profile.new
    profile.errors.add(:id,"profile could not be found")
    profile
  end


end

def create_trophy(title,desc,credits,image_url)
  trophy = Trophy.new
  trophy.title= title
  trophy.desc= desc
  trophy.credits = credits
  trophy.hidden = true
  trophy.image = URI.parse(image_url)
  trophy.save
end
def create_trophies(front_end_db)
  results = front_end_db.query("SELECT * FROM  `Trophy` ",
                              :cache_rows => false)
  results.each do |row|
    t = Trophy.find_by_title(row['name'])
    if t.nil?
      credits = row['credits'].to_i* APP_CONFIG['nereus_to_credit_conversion']
      url = "http://www.theskynet.org/images/trophies/%03d.png" % row['id']
      create_trophy(row['name'],row['description'],credits,url)
    end
  end
end
def update_bonus_credit(front_end_db)
  print "-- Starting Bonus Credit import \n"

  results = front_end_db.query("SELECT * FROM  `bonusCredits` ",
                               :cache_rows => false)
  num_results = results.size
  print "-- found #{num_results} bonus credit entries \n"
  j= 0
  results.each do |row|
    print "-- importing bonus credit items #{j} to #{j+10} \n" if j%10 == 0
    profile = get_profile_by_nereus_id(row['userID'])
    if profile
      bonus = BonusCredit.new(:amount => row['credits']* APP_CONFIG['nereus_to_credit_conversion'], :reason => "imported from old site")
      bonus.created_at = Time.at(row['day'].to_i*86400)
      profile.general_stats_item.bonus_credits << bonus
    end
    j += 1
  end
end

def fix_credit_with_bonus(front_end_db)
  print "-- fixing user credits  \n"
  print "-- -- loading old totals"
  results = front_end_db.query("SELECT * FROM  `totalCredits` ",
                               :cache_rows => false)
  num_results = results.size
  print "-- found #{num_results} credit entries \n"
  j= 0
  results.each do |row|
    print "-- importing bonus credit items #{j} to #{j+10} \n" if j%10 == 0

    nereus_item = NereusStatsItem.find_by_nereus_id(row['userID'].to_i)
    if nereus_item
      diff = row['credits'].to_i* APP_CONFIG['nereus_to_credit_conversion'] - nereus_item.credit.to_i
      #only add bonus credits if old credits were higher
      if diff.to_i > 0
        profile = nereus_item.general_stats_item.profile if nereus_item.general_stats_item
        if profile
          bonus = BonusCredit.new(:amount => diff, :reason => "Fix for old site conversion")
          print "-- -- Adding #{diff} cr to old_id: #{row['userID']} \n"
          bonus.created_at = Time.at(row['day'].to_i*86400)
          profile.general_stats_item.bonus_credits << bonus
        end
      end
    end
    j += 1
  end
  print "-- finished fixing credits"
end

def connect_boinc_users
  boinc_users = BoincStatsItem.where{(credit > 0) & (general_stats_item_id == nil)}
  boinc_users.each do |boinc_user|
    #get their email from the boinc server
    remote_email = boinc_user.get_name_and_email[:email]

    #see if they have a skynet account
    user = User.find_by_email(remote_email)
    #if so connec them
    if !user.nil?
      user.profile.general_stats_item.boinc_stats_item = boinc_user

    end

  end
end