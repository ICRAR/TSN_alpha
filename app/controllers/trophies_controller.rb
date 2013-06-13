class TrophiesController < ApplicationController
  load_and_authorize_resource
  def show
    if user_signed_in?
      @trophy = current_user.profile.trophies.where(:id => params[:id]).first || not_found
    else
      redirect_to root_url, :alert => "Sorry you must be logged into do that"
    end
  end
end
