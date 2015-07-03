class BoincResultsQuickFixJob < Delayed::BaseScheduledJob
  run_every 6.hours

  def perform
    BoincResult.where{server_state == 1}.update_all(server_state: 2)
  end
end