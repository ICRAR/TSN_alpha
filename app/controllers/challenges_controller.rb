class ChallengesController < ApplicationController
  # GET /alliances
  # GET /alliances.json
  authorize_resource
  helper_method :sort_column, :sort_direction
  def create
    redirect_to root_url, :notice => "You must be logged in to do that" unless user_signed_in? && user_is_admin?
    @challenge = Challenge.new(params[:challenge])
    if @challenge.save
      redirect_to @challenge
    else
      render :new
    end
  end

  def new
    redirect_to root_url, :notice => "You must be logged in to do that" unless user_signed_in? && user_is_admin?
    @challenge = Challenge.new()
  end

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

    if user_signed_in?
      @comment = Comment.new(:commentable => @challenge)
      @comment.profile = current_user.profile
    end

    render :show
  end

  def join
    redirect_to root_url, :notice => "You must be logged in to do that" unless user_signed_in?
    challenge = Challenge.not_hidden(user_is_admin?).find(params[:id])
    error_msg = ''
    if challenge.joinable?(challenge.invite_code)
      profile = current_user.profile
      case challenge.challenger_type.downcase
        when 'alliance'
          #check if current user is a alliance leader
          error_msg = 'You must be the leader of an Alliance to join this challenge.' if profile.alliance_leader_id.nil? || profile.alliance_leader_id == 0
          #check if their alliance is already in the challenge
          error_msg = 'Your alliance is already participating in this challenge.' if challenge.challengers.where{entity_id == my{profile.alliance_leader_id}}.exists?
        when 'profile'
          #check if current user is already in the challenge
          error_msg = 'You are already participating in this challenge.' if challenge.challengers.where{entity_id == my{profile.id}}.exists?
      end
    else
      error_msg = 'This challenge can not be joined at the moment'
    end

    #now if error msg is still == '' then this user is allowed to join
    if error_msg == ''
      #check invite code
      if challenge.joinable?(params[:invite_code])
        case challenge.challenger_type.downcase
          when 'alliance'
            new_challenger = challenge.join profile.alliance_leader, params[:invite_code]
          when 'profile'
            new_challenger = challenge.join profile, params[:invite_code]
        end
        if new_challenger == false
          error_msg = 'This challenge can not be joined at the moment'
        else
          if new_challenger.class == Challenger
            error_msg = "Oh no something went wrong: #{new_challenger.errors.messages}" unless new_challenger.errors.messages == {}
          else
            error_msg = "Oh no something went wrong"
          end
        end
      else
        error_msg = "Sorry you need the correct invite code."
      end
    end
    #if there has been an error ie error_msg != '' then flash error
    if error_msg == ''
      redirect_to challenge_path(challenge), notice: 'Congratulations you are now signed up for this challenge.'
    else
      redirect_to challenge_path(challenge), alert: error_msg
    end

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