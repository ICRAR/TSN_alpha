class TheSkyMap::CurrentProfileSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_signed_in, :user_id, :email,
             :base_x, :base_y, :base_z

  def base_x
    3
  end
  def base_y
    5
  end
  def base_z
    7
  end

  def email
    @object.user.email
  end

  def user_signed_in
    true
  end

end