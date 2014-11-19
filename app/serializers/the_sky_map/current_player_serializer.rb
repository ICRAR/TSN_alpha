class TheSkyMap::CurrentPlayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_signed_in, :profile_id, :email, :game_map_id,
             :home_x, :home_y, :currency_available, :currency_available_special,
             :total_score, :total_income, :total_income_special, :player_options, :unread_msg_count,
             :mini_map_x_min, :mini_map_x_max, :mini_map_y_min, :mini_map_y_max
  def player_options
    @object.options
  end
  def home_x
    @object.home.x
  end
  def home_y
    @object.home.y
  end

  def mini_map_x_min
    @object.game_map.x_min
  end
  def mini_map_x_max
    @object.game_map.x_max
  end
  def mini_map_y_min
    @object.game_map.y_min
  end
  def mini_map_y_max
    @object.game_map.y_max
  end

  def email
    @object.profile.user.email
  end
  def name
    @object.profile.name
  end

  def user_signed_in
    true
  end

end