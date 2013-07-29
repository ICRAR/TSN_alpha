namespace :schedule_jobs do

  desc "starts up all scheduled jobs"
  task :start => :environment do
    #TestJob.schedule
    puts 'starting Boinc Update'
    BoincJob.schedule
    end
  desc "stops up all scheduled jobs"
  task :stop => :environment do
    #TestJob.unschedule
    puts 'stopping Boinc Update'
    BoincJob.unschedule
  end
end