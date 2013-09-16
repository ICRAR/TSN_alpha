class TrophiesController < ApplicationController
  load_and_authorize_resource
  def show
    if user_signed_in?
      @trophy_ids = current_user.profile.trophy_ids
    else
      @trophy_ids = nil
    end

    @trophy = Trophy.find(params[:id])
    if params[:show_all]
      @profiles = @trophy.profiles.select([:id, :first_name, :second_name, :use_full_name, :nickname]).select{user.username.as(user_name)}.joins{:user}
    end

    @set = @trophy.trophy_set
  end
end
