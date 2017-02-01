APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require 'rails/commands'

def kill_bad_users 
  
  count = 0
  puts "starting..."
  
 # User.joins("INNER JOIN theskynet.profiles ON theskynet.profiles.user_id = theskynet.users.id
 # INNER JOIN theskynet.general_stats_items ON theskynet.profiles.id = theskynet.general_stats_items.profile_id")
 #             .where("sign_in_count = 0 and total_credit = 0 and users.created_at > '2014/01/01'").find_each do |user

  User.where("sign_in_count = 0").find_each do |user|
    puts "Destroyed #{user.username} : #{count}"
    user.my_destroy
    count += 1
  end
end

kill_bad_users
