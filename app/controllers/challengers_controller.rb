class ChallengersController < ApplicationController
  authorize_resource
  def show
    @challenge = Challenge.not_hidden(user_is_admin?).find(params[:challenge_id])
    @challenger = Challenger.find(params[:id])
  end

  def compare
    @challenge = Challenge.not_hidden(user_is_admin?).find(params[:challenge_id])
    ids = params[:ids]
    ids = [] if ids.nil?
    @challengers = Challenger.includes(:entity, :metrics).where{(challenge_id == my{@challenge.id}) & (id.in ids)}.order{rank.asc}
  end
end