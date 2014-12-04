class TheSkyMap::QuadrantSerializer < TheSkyMap::TheSkyMapSerializer
  attributes :id, :x, :y, :name, :explored, :explored_fully, :explored_partial, :colour,
             :home, :mine, :hostile, :unowned, :total_score, :total_income, :location, :galaxy_id, :thumbnail_src, :game_map_id
  embed :id, include: true
  has_many :the_sky_map_ships, key: :ship_ids, root: :ships, include: false
  has_many :the_sky_map_bases, key: :base_ids, root: :bases, include: false
  has_one  :owner, key: :player_id, root: :players, include: false
  def include_the_sky_map_ships?
    explored?
  end
  def include_the_sky_map_bases?
    explored?
  end
  def include_owner
    explored?
  end
  def home
    home_id = current_player.home_id
    home_id == object.id
  end
  def mine
    object.owner_id == current_player.id
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
  def thumbnail_src
    if explored? || explored_partial
      #return either galaxy thumbnail or url to quadrant type image
      if object.thumbnail_link.nil? || object.thumbnail_link == ''
        image_path(object.the_sky_map_quadrant_type.thumbnail_path)
      else
        return object.thumbnail_link
      end
    else
      #return unexplored image
     image_path('the_sky_map/unexplored.jpg')
    end
  end

  #type object
  attributes :num_bases, :desc
  def num_bases
    explored? ? object.the_sky_map_quadrant_type.num_of_bases : 0
  end
  def desc
    explored? ? object.the_sky_map_quadrant_type.desc : '-'
  end

  def location
    {
        x: object.x,
        y: object.y,
        quadrant_id: object.id
    }
  end
end