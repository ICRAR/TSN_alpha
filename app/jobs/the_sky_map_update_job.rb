class TheSkyMapUpdateJob < Delayed::BaseScheduledJob
  run_every 60.minutes
  def perform
    TheSkyMap::GameMap.all.each do |game_map|
      game_map.update_map
    end
  end
end