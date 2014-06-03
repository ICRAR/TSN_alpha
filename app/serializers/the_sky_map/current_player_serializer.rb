class TheSkyMap::CurrentPlayerSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_signed_in, :profile_id, :email,
             :home_x, :home_y, :home_z, :currency_available, :currency_available_special,
             :total_score, :total_income

  def home_x
    @object.home.x
  end
  def home_y
    @object.home.y
  end
  def home_z
    @object.home.z
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