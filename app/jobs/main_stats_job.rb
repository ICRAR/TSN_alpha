class MainStatsJob < Delayed::BaseScheduledJob
  run_every 30.minutes
  def perform
    t = Time.now
    BoincJob.run_once t
    StatsGeneralJob.run_once t+1
    StatsAlliancesJob.run_once t+2
  end
end