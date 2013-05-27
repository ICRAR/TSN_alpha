class TrophiesController < ApplicationController
  load_and_authorize_resource
  def show
    @trophy = Trophy.find(params[:id])
  end
end
