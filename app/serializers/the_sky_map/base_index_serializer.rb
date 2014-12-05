class TheSkyMap::BaseIndexSerializer < TheSkyMap::TheSkyMapSerializer
  attributes :id, :desc, :hostile, :mine, :type, :score, :income, :attack, :remaining_health, :max_health
  embed :ids#, include: true
  #has_one :the_sky_map_quadrant, key: :quadrant_id
  attributes the_sky_map_quadrant_id: :quadrant_id
  attributes the_sky_map_player_id: :player_id
  attributes display_name: :name

  def desc
    object.the_sky_map_base_upgrade_type.desc
  end
  def score
    object.the_sky_map_base_upgrade_type.score
  end
  def income
    object.the_sky_map_base_upgrade_type.income
  end
  def type
    object.the_sky_map_base_upgrade_type.name
  end
  def attack
    object.the_sky_map_base_upgrade_type.attack
  end
  def max_health
    object.the_sky_map_base_upgrade_type.health
  end
  def mine
    object.the_sky_map_player_id == current_player.id
  end
  def hostile
    !(mine)
  end

  attributes :colour
  def colour
    object.the_sky_map_quadrant.owner.colour
  end
end