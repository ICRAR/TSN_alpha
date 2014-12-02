class TheSkyMap::BaseSerializer < TheSkyMap::BaseIndexSerializer
  attributes :location
  def location
    {
        x: object.the_sky_map_quadrant.x,
        y: object.the_sky_map_quadrant.y,
        quadrant_id: object.the_sky_map_quadrant.id
    }
  end
end