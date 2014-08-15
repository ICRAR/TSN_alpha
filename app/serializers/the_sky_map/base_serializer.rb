class TheSkyMap::BaseSerializer < TheSkyMap::BaseIndexSerializer
  attributes :game_actions_available, :location
  has_many :actions, include: true

  def game_actions_available
    if  mine
      object.actions_available_array(object.the_sky_map_quadrant.owner)
    end
  end

  def actions
    object.actions.order{id.desc}.limit(10)
  end
  def include_actions?
    mine
  end
  def location
    {
        x: object.the_sky_map_quadrant.x,
        y: object.the_sky_map_quadrant.y,
        z: object.the_sky_map_quadrant.z,
    }
  end
end