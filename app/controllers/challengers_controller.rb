class ChallengersController < ApplicationController
  authorize_resource
  def show
    @challenger = Challenger.find(params[:id])
  end

  def compare
    @challenge = Challenge.find(params[:challenge_id])
    ids = params[:ids]
    ids = [] if ids.nil?
    @challengers = Challenger.includes(:entity, :metrics).where{(challenge_id == my{@challenge.id}) & (id.in ids)}.order{rank.asc}
  end
end