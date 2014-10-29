class TheSkyMap::ActionableSerializer < ActiveModel::Serializer
  attributes :id
  attributes :game_actions_available
  has_many :actions, include: true, key: 'actions'
  embed :ids
  def game_actions_available
    if  current_user.profile.the_sky_map_player.id == object.the_sky_map_player_id
      object.actions_available_array(current_user.profile.the_sky_map_player)
    end
  end

  def actions
    object.actions.order{id.desc}.limit(10)
  end
  def include_actions?
    current_user.profile.the_sky_map_player.id == object.the_sky_map_player_id
  end
end