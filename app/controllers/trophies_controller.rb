class TrophiesController < ApplicationController
  authorize_resource
  def show
    if user_signed_in?
      @trophy_ids = current_user.profile.trophy_ids
    else
      @trophy_ids = nil
    end

    @trophy = Trophy.find(params[:id])

    if user_signed_in?
      @comment = Comment.new(:commentable => @trophy)
      @comment.profile = current_user.profile
    end

    @set = @trophy.trophy_set
  end
  def promote
    unless user_signed_in?
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
    end
    trophy_item = current_user.profile.profiles_trophies.where{trophy_id == my{params[:id]}}.first
    if trophy_item.nil?
      redirect_to my_profile_path, alert: 'Sorry we could not find that trophy.'
    end
    promote_value = params[:value].to_i
    trophy_item.promote_to promote_value
    trophy_item.save
    redirect_to trophies_profile_path(:id => current_user.profile.id, :style => "priority"),
                notice: "Success"
  end
  def demote
    unless user_signed_in?
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
    end
    trophy_item = current_user.profile.profiles_trophies.where{trophy_id == my{params[:id]}}.first
    if trophy_item.nil?
      redirect_to my_profile_path, alert: 'Sorry we could not find that trophy.'
    end
    demote_value = params[:value].to_i
    trophy_item.demote_to demote_value
    trophy_item.save
    redirect_to trophies_profile_path(:id => current_user.profile.id, :style => "priority"),
                notice: "Success"
  end
end
