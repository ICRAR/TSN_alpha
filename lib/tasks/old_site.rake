namespace :old_site do

  desc "loads data from external site"
  task :load => :environment do
    #requries the user to set run_check=true at runtime to stop accidental running
    return false unless ENV['run_check'] == 'true'


    #connect to old front end db
    remote_client = Mysql2::Client.new(:host => APP_CONFIG['nereus_host_front_end'], :username => APP_CONFIG['nereus_username_front_end'], :database => APP_CONFIG['nereus_database_front_end'], :password => APP_CONFIG['nereus_password_front_end'])

    #*********add users************
    #load accounts
    print "fetching accounts \n"
    results = remote_client.query("SELECT * FROM `Account` WHERE   `userID` >= 100000 AND `userID` <= 900000 LIMIT 0 , 30",
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
    #************import alliances *****************

    #************update stats trophies ranks ect ***************

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
  new_user = User.new(
      :email => old_user[:email],
      :username => old_user[:username],
      :password => 'password',
      :password_confirmation => 'password',
  )
  #new_user.confirmed_at = Time.now.utc,
  new_user.skip_confirmation!
  if new_user.save
    #populate User field
    new_user.encrypted_password = old_user[:password]
    new_user.old_site_password_salt = old_user[:salt]
    new_user.admin = true if old_user[:username] == 'eckley'  # hack to to auto generate myself as admin
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

    #update nereus object
      nereus.network_limit = old_user[:network_limit]
      nereus.paused = old_user[:paused]
    end
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
      :paused       => row['paused'].to_i == 1 ? true: false
  }
end
