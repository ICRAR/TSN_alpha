class ChallengersController < ApplicationController
  authorize_resource
  def show
    @challenger = Challenger.find(params[:id])
  end
end