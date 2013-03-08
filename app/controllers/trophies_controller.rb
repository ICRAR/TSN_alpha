class TrophiesController < ApplicationController
  load_and_authorize_resource
  def show
    @trophy = Trophy.find(params[:id],:include => "profiles")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end
end
