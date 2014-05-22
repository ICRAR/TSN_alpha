class TheSkyMap::ShipSerializer < ActiveModel::Serializer
  attributes :id, :name, :attack, :health, :speed, :desc
  embed :ids#, include: true
  has_one :the_sky_map_quadrant, key: :quadrant_id
  #def the_sky_map_quadrant
  #  TheSkyMap::Quadrant.for_show(current_user.profile.the_sky_map_player).find(object.the_sky_map_quadrant_id)
  #end
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

end