class Sub::CurrentProfileSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_signed_in, :user_id, :email

  def email
    @object.user.email
  end

  def user_signed_in
    true
  end

end