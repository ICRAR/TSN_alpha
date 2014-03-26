namespace :schedule_jobs do

  desc "starts up all scheduled jobs"
  task :start => :environment do
    #TestJob.schedule
    puts 'starting Main(Boinc => StatsGeneral => StatsAlliance) job'
    MainStatsJob.schedule Time.now
    puts 'starting Boinc Copy Update'
    BoincCopyJob.schedule Time.now
    puts 'starting Trophy Update'
    TrophiesJob.schedule Time.now
    puts 'starting elastic search check'
    ElasticSearchJob.schedule Time.now
    end
  desc "stops up all scheduled jobs"
  task :stop => :environment do
    #TestJob.unschedule
    puts 'stopping Boinc Update'
    BoincJob.unschedule
    puts 'stopping Boinc Copy Update'
    BoincCopyJob.unschedule
    puts 'stopping Trophy Update'
    TrophiesJob.unschedule
    puts 'stopping Nereus Update'
    NereusJob.unschedule
    puts 'stopping stats general Update'
    StatsGeneralJob.unschedule
    puts 'stopping stats alliances Update'
    StatsAlliancesJob.unschedule
    puts 'stopping Main job Update'
    MainStatsJob.unschedule
    puts 'starting elastic search check'
    ElasticSearchJob.unschedule
  end
end