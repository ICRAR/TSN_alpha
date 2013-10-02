class TrophiesController < ApplicationController
  load_and_authorize_resource
  def show
    if user_signed_in?
      @trophy_ids = current_user.profile.trophy_ids
    else
      @trophy_ids = nil
    end

    @trophy = Trophy.find(params[:id])

    @set = @trophy.trophy_set
  end
end
