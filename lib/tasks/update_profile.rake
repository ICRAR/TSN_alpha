namespace :custom do

  desc "fixes profiles"
  task :update_profile => :environment do

    print "\n Starting fix \n"
    profiles = Profile.all
    profiles.each do |profile|
      print "profile = #{profile.name} \n"
        if profile.general_stats_item
          print "Profile #{profile.id} is good\n"
        else
          profile.build_general_stats_item
          profile.save
          print "Profile #{profile.id} was updated\n"
        end
    end
  end
end