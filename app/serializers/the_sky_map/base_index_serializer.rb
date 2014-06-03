class TheSkyMap::BaseIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :desc, :hostile, :mine, :type
  embed :ids#, include: true
  has_one :the_sky_map_quadrant, key: :quadrant_id
  def desc
    object.the_sky_map_base_upgrade_type.desc
  end
  def type
    object.the_sky_map_base_upgrade_type.name
  end
  def mine
    object.the_sky_map_quadrant.owner_id == current_user.profile.the_sky_map_player.id
  end
  def hostile
    !(mine)
  end
end