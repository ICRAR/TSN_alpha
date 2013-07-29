namespace :schedule_jobs do

  desc "starts up all scheduled jobs"
  task :start => :environment do
    #TestJob.schedule
    BoincJob.schedule
    end
  desc "stops up all scheduled jobs"
  task :stop => :environment do
    #TestJob.unschedule
    BoincJob.unschedule
  end
end