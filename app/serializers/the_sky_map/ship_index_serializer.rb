class TheSkyMap::ShipIndexSerializer < TheSkyMap::TheSkyMapSerializer
  attributes :id, :name, :attack, :heal, :speed, :desc, :hostile, :mine, :remaining_health, :max_health
  embed :ids#, include: true
  #has_one :the_sky_map_quadrant, key: :quadrant_id
  #has_one :the_sky_map_player, key: :player_id
  attributes the_sky_map_quadrant_id: :quadrant_id
  attributes the_sky_map_player_id: :player_id

  def attack
    object.the_sky_map_ship_type.attack
  end
  def heal
    object.the_sky_map_ship_type.heal
  end
  def desc
    object.the_sky_map_ship_type.desc
  end
  def speed
    object.the_sky_map_ship_type.speed
  end
  def mine
    object.the_sky_map_player_id == current_player.id
  end
  def hostile
    !(mine)
  end

  def max_health
    object.the_sky_map_ship_type.health
  end

  attributes :colour
  def colour
    object.the_sky_map_player.colour
  end

end