class TheSkyMap::ShipIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :attack, :health, :speed, :desc, :hostile, :mine
  embed :ids#, include: true
  has_one :the_sky_map_quadrant, key: :quadrant_id
  has_one :the_sky_map_player, key: :player_id
  def name
    "#{object.the_sky_map_ship_type.name}:#{object.id}"
  end
  def attack
    object.the_sky_map_ship_type.attack
  end
  def desc
    object.the_sky_map_ship_type.desc
  end
  def health
    object.the_sky_map_ship_type.health
  end
  def speed
    object.the_sky_map_ship_type.speed
  end
  def mine
    object.the_sky_map_player_id == current_user.profile.the_sky_map_player.id
  end
  def hostile
    !(mine)
  end
end