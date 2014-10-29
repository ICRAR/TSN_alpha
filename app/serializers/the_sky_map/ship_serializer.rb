class TheSkyMap::ShipSerializer < TheSkyMap::ShipIndexSerializer
  attributes :location
  def location
    {
        x: object.the_sky_map_quadrant.x,
        y: object.the_sky_map_quadrant.y,
        z: object.the_sky_map_quadrant.z,
    }
  end
end