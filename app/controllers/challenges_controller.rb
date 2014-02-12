class ChallengesController < ApplicationController
  # GET /alliances
  # GET /alliances.json
  authorize_resource
  helper_method :sort_column, :sort_direction
  def index
    per_page = [params[:per_page].to_i,1000].min
    per_page ||= 20

    @challenges = Challenge.not_hidden(user_is_admin?).page(params[:page]).per(per_page).order("`" + sort_column + "`" " " + sort_direction).includes(:manager)
  end

  def show
    @per_page = params[:per_page].to_i
    @per_page = 20 if @per_page == 0
    @page =  params[:page].to_i
    @page = 1 if @page == 0
    @challenge = Challenge.not_hidden(user_is_admin?).find(params[:id])
    @challengers = Challenger.page(@page).per(@per_page).includes(:entity).where{challenge_id == my{@challenge.id}}.order{rank.asc}
  end

  private

  def sort_column
    %w[start_date end_date name].include?(params[:sort]) ? params[:sort] : "start_date"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end