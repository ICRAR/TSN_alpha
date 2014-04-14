class SocialController < ApplicationController
  before_filter :signed_in, :except => [:timeline]


  def like_model
    object = likable_object
    return redirect_to( root_url, notice: 'Sorry could not find that object') if object.nil?
    profile = current_user.profile
    profile.like!(object)
    Profile.delay.timeline_like(profile.id,object.class.to_s,object.id)

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

  def timeline
    page = params[:page].to_i || 1
    if params[:profile_id]
      if params[:profile_id] == 'all' && user_is_admin?
        @timeline = TimelineEntry.get_timeline_all.page(page).per(3)

      else
        profile = Profile.find params[:profile_id]
        @timeline = profile.own_timeline.page(page).per(3)
      end
    elsif params[:alliance_id]
      alliance = Alliance.find params[:alliance_id]
      @timeline = alliance.own_timeline.page(page).per(3)
    else
      signed_in
      @timeline = current_user.profile.followees_timeline.page(page).per(3)
    end

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


end