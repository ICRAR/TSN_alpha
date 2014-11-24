class TheSkyMap::MessageIndexSerializer < TheSkyMap::TheSkyMapSerializer
  attributes :id, :msg, :created_at, :created_at_int, :ack
  embed :ids#, include: true
  has_one :the_sky_map_quadrant, key: :quadrant_id
  def created_at_int
    object.created_at.to_i
  end
end