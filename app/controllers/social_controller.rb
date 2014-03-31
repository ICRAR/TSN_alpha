class SocialController < ApplicationController
  before_filter :signed_in, :except => []
  def signed_in
    redirect_to( root_url, notice: 'Sorry could must be signed in to do that') unless user_signed_in?
  end

  def like_model
    object = likable_object
    return redirect_to( root_url, notice: 'Sorry could not find that object') if object.nil?
    profile = current_user.profile
    profile.like!(object)
    redirect_to after_sign_in_path_for, notice: 'Success, your like was counted.'
  end
  def unlike_model
    object = likable_object
    return redirect_to( root_url, notice: 'Sorry could not find that object') if object.nil?
    profile = current_user.profile
    profile.unlike!(object)
    redirect_to after_sign_in_path_for, notice: 'Success, your like was counted.'
  end

  private
  def likable_model
    return nil if params[:model_type].nil?
    model_name = %w[Trophy Alliance].include?(params[:model_type]) ? params[:model_type] : nil
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