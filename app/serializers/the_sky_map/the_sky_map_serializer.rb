class TheSkyMap::TheSkyMapSerializer < ActiveModel::Serializer
  def current_player
    current_user.profile.the_sky_map_current_player
  end
end