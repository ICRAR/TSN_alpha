class TheSkyMap::CurrentPlayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_signed_in, :profile_id, :email, :game_map_id,
             :home_x, :home_y, :currency_available, :currency_available_special,
             :total_score, :total_income, :total_income_special, :player_options, :unread_msg_count
  def player_options
    @object.options
  end
  def home_x
    @object.home.x
  end
  def home_y
    @object.home.y
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