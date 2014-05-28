class TheSkyMap::QuadrantSerializer < ActiveModel::Serializer
  attributes :id, :x, :y, :z, :name, :explored, :explored_fully, :explored_partial,
             :home, :mine, :hostile, :unowned
  embed :ids#, include: true
  has_many :the_sky_map_ships, key: :ship_ids, root: :ships, serializer: TheSkyMap::ShipIndexSerializer
  def include_the_sky_map_ships?
    explored?
  end

  def home
    home_id = scope.profile.the_sky_map_player.home_id
    home_id == object.id
  end
  def mine
    object.owner_id == scope.profile.the_sky_map_player.id
  end
  def hostile
    explored? && !object.owner_id.nil? && !mine
  end
  def unowned
    explored? && object.owner_id.nil?
  end
  def name
    if object.explored.nil?
      '?'
    elsif object.explored == 0
      object.the_sky_map_quadrant_type.unexplored_name
    else
      object.the_sky_map_quadrant_type.name
    end
  end
  def explored_fully
    explored?
  end
  def explored_partial
    !object.explored.nil? && !explored?
  end
  def explored?
    object.explored == 1
  end

  #type object
  attributes :base_score, :num_bases, :desc, :color
  def base_score
    explored? ? object.the_sky_map_quadrant_type.score : 0
  end
  def num_bases
    explored? ? object.the_sky_map_quadrant_type.num_of_bases : 0
  end
  def desc
    explored? ? object.the_sky_map_quadrant_type.desc : '-'
  end
  def color
    if object.explored.nil?
      'unknown'
    elsif object.explored == 0
      object.the_sky_map_quadrant_type.unexplored_color
    else
      object.the_sky_map_quadrant_type.explored_color
    end
  end
end