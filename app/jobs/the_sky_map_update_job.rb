class TheSkyMapUpdateJob < Delayed::BaseScheduledJob
  run_every 60.minutes
  def perform
    #first update special income from RAC values
    TheSkyMap::Player.update_special_income

    #first update both currencies
    TheSkyMap::Player.update_currency

    #update player rankings
    TheSkyMap::Player.update_rankings
  end
end