class SocialController < ApplicationController
  before_filter :signed_in, :except => []


  def like_model
    object = likable_object
    return redirect_to( root_url, notice: 'Sorry could not find that object') if object.nil?
    profile = current_user.profile
    profile.like!(object)
    if likable_model == Comment
     Comment.delay.like_comment(object.id,profile.id)
    end
    redirect_to after_sign_in_path_for, notice: 'Success, your like was counted.'
  end
  def unlike_model
    object = likable_object
    return redirect_to( root_url, notice: 'Sorry could not find that object') if object.nil?
    profile = current_user.profile
    profile.unlike!(object)
    redirect_to after_sign_in_path_for, notice: 'Success, your like was removed.'
  end

  def follow
    followee = Profile.find params[:id]
    follower = current_user.profile
    follower.follow! followee
    Profile.delay.notify_follow followee.id, follower.id
    redirect_to after_sign_in_path_for, notice: "Success, you are now following #{followee.name}."
  end
  def unfollow
    followee = Profile.find params[:id]
    follower = current_user.profile
    follower.unfollow! followee
    redirect_to after_sign_in_path_for, notice: "Success, you are no longer following #{followee.name}."
  end

  private
  def likable_model
    return nil if params[:model_type].nil?
    model_name = %w[Trophy Alliance Comment].include?(params[:model_type]) ? params[:model_type] : nil
    return nil if model_name.nil?
    return model_name.constantize
  end

  def likable_object
    return nil if params[:model_id].nil?
    model = likable_model
    return nil if model.nil?
    return model.find(params[:model_id])
  end

  def signed_in
    redirect_to( root_url, notice: 'Sorry could must be signed in to do that') unless user_signed_in?
  end
end