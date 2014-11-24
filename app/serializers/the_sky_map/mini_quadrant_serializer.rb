class TheSkyMap::MiniQuadrantSerializer < TheSkyMap::TheSkyMapSerializer
  attributes :id, :x, :y, :explored, :explored_fully, :explored_partial,
             :home, :mine, :hostile, :unowned, :symbol, :game_map_id
  #embed :ids#, include: true
  #has_one  :owner, key: :player_id
  attributes owner_id: :player_id
  def include_player_id
    explored?
  end
  def symbol
    if home
      'H'
    else
      explored_fully ?
          object.the_sky_map_quadrant_type.explored_symbol :
          object.the_sky_map_quadrant_type.unexplored_symbol
    end
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

  def explored_fully
    explored?
  end
  def explored_partial
    !object.explored.nil? && !explored?
  end
  def explored?
    object.explored == 1
  end
end