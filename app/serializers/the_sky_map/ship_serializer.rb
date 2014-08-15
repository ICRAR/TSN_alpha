class TheSkyMap::ShipSerializer < TheSkyMap::ShipIndexSerializer
  attributes :game_actions_available, :location
  has_many :actions, include: true

  def game_actions_available
    if  current_user.profile.the_sky_map_player.id == object.the_sky_map_player_id
      object.actions_available_array(object.the_sky_map_player)
    end
  end

  def actions
    object.actions.order{id.desc}.limit(10)
  end
  def include_actions?
    current_user.profile.the_sky_map_player.id == object.the_sky_map_player_id
  end
  def location
    {
        x: object.the_sky_map_quadrant.x,
        y: object.the_sky_map_quadrant.y,
        z: object.the_sky_map_quadrant.z,
    }
  end
end