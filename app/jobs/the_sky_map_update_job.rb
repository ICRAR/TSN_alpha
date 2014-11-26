class TheSkyMapUpdateJob < Delayed::BaseScheduledJob
  run_every 60.minutes
  def perform
    #first update special income from RAC values
    #TheSkyMap::Player.update_special_income
    #temp hack to update RAC from main server
    TheSkyMap::Player.all.each do |player|
      remote = HTTParty.get("http://www.theskynet.org/profiles/#{player.profile_id}.json")
      puts "checking http://www.theskynet.org/profiles/#{player.profile_id}.json"
      unless remote.parsed_response['result']['profile'].nil?
        rac = remote.parsed_response['result']['profile']['boinc_stats_item']['RAC']
        income = Math.log([rac,1].max)
        player.total_income_special = income
        player.save
      end
    end
    #first update both currencies
    TheSkyMap::Player.update_currency

    #update player rankings
    TheSkyMap::Player.update_rankings
  end
end