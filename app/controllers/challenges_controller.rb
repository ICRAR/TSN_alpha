class ChallengesController < ApplicationController
  # GET /alliances
  # GET /alliances.json
  authorize_resource
  helper_method :sort_column, :sort_direction
  def index
    per_page = [params[:per_page].to_i,1000].min
    per_page ||= 20
    search_options = []
    search_options << "challenges.name LIKE \"%#{Mysql2::Client.escape(params[:name])}%\"" if params[:name] != nil  && params[:name] != ''
    search_options << "challenges.start_date >= \"#{Time.parse(params[:start_date_from])}\"" if params[:start_date_from] != nil && params[:start_date_from] != ''
    search_options << "challenges.start_date <= \"#{Time.parse(params[:start_date_to])}\"" if params[:start_date_to] != nil && params[:start_date_to] != ''
    search_options << "challenges.end_date >= \"#{Time.parse(params[:end_date_from])}\"" if params[:end_date_from] != nil && params[:end_date_from] != ''
    search_options << "challenges.end_date <= \"#{Time.parse(params[:end_date_to])}\"" if params[:end_date_to] != nil && params[:end_date_to] != ''
    search_options << "challenges.started =  0" if params[:status] != nil && params[:status] == 'upcoming'
    search_options << "challenges.started =  1 AND challenges.finished = 0" if params[:status] != nil && params[:status] == 'running'
    search_options << "challenges.finished = 1" if params[:status] != nil && params[:status] == 'finished'
    search_options = search_options.join(' AND ')

    @challenges = Challenge.not_hidden(user_is_admin?).page(params[:page]).per(per_page).where(search_options).order("`" + sort_column + "`" " " + sort_direction).includes(:manager)
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
    sort = %w[start_date end_date name status].include?(params[:sort]) ? params[:sort] : "start_date"
    sort = "started` #{sort_direction}, `finished" if sort == 'status'
    sort
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end