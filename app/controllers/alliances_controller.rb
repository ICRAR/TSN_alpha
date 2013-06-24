class AlliancesController < ApplicationController
  # GET /alliances
  # GET /alliances.json
  authorize_resource
  helper_method :sort_column, :sort_direction

  def index
    per_page = params[:per_page]
    per_page ||= 20
    @alliances = Alliance.for_leaderboard.page(params[:page]).per(per_page).order("`" + sort_column + "`" " " + sort_direction)
  end

  # GET /alliances/1
  # GET /alliances/1.json
  def show
    per_page = params[:per_page]
    per_page ||= 20
    @alliance = Alliance.for_show(params[:id])
    @members = AllianceMembers.page(params[:page]).per(per_page).for_alliance_show(params[:id])
    @total_members  = AllianceMembers.where(:alliance_id =>params[:id]).count
  end

  # GET /alliances/new
  # GET /alliances/new.json
  def new
    if current_user.profile.alliance
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    end
    @alliance = Alliance.new
  end

  # GET /alliances/1/edit
  def edit
    @alliance = Alliance.find(params[:id], :include => 'members')
  end

  # POST /alliances
  # POST /alliances.json
  def create
    if current_user.profile.alliance
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    end

    @alliance = Alliance.new(params[:alliance])
    @alliance.ranking = Alliance.calculate(:maximum,'ranking') + 1
    @alliance.credit = 0
    if @alliance.save
      current_user.profile.join_alliance @alliance

      @alliance.leader = current_user.profile

      redirect_to @alliance, notice: 'Alliance was successfully created.'
    else
      render :new
    end

  end

  # PUT /alliances/1
  # PUT /alliances/1.json
  def update
    @alliance = Alliance.find(params[:id])
    if params[:alliance][:leader] != @alliance.leader.id
      #change leader
      flash[:alert] = @alliance.leader = Profile.find(params[:alliance][:leader])
    end

    if @alliance.update_attributes(params[:alliance].except('leader'))
      redirect_to @alliance, notice: 'Alliance was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /alliances/1
  # DELETE /alliances/1.json
  def destroy
    @alliance = Alliance.find(params[:id])
    #@alliance.destroy
  end

  def join
      @alliance = Alliance.find(params[:id])
      #check that the current user irofile.sn't already part of an alliance
      if current_user.profile.alliance
        flash[:notice] = 'Sorry you can only be part of a single alliance'

      else
        current_user.profile.join_alliance @alliance
        flash[:notice] = "Welcome to the #{@alliance.name} Alliance"
      end

      redirect_to my_profile_path
  end

  def leave
    @alliance = current_user.profile.alliance

    #first check that the user has a current alliance membership
    if !@alliance
      flash[:notice] = 'Sorry you must join an alliance before you can leave an alliance'
    #check that user is not the alliance leader
    elsif current_user.profile.alliance_leader
      flash[:notice] = 'Sorry the current leader cannot leave an alliance'
    else
    #remove user from alliance
    current_user.profile.leave_alliance
    flash[:notice] = "You have left the #{@alliance.name} alliance"
    end
    redirect_to my_profile_path
  end
  def search
    #@alliances = Alliance.search_by_name(params[:search]).includes(:leader).page(params[:page]).per(10)
    @alliances = Alliance.search params[:search], params[:page], 10

    render :index
  end

  def invite
    email = params[:email]
    alliance = Alliance.find(params[:id])
    success = false
    msg = ''
    #check if current user is a member of the alliance
    if email != ""
      if user_signed_in? && current_user.profile.alliance == alliance && current_user.email != email
        #check if the invited email is a current member
        user = User.find_by_email(email)
        profile = user.profile if user
        if profile
          #check that the invited member is not a leader of another alliance
          if profile.alliance_leader == nil
            #create invite
            invite = AllianceInvite.new(:email => email)
            invite.alliance_id = alliance.id
            invite.invited_by_id =  current_user.profile.id
            invite.save

            #send email
            UserMailer.alliance_invite(invite).deliver
            #return success
            success = true
            msg = "Invite for #{Alliance.name} sent to #{email}"
          else
            #error
            success = false
            msg = "User #{email} is a currently a leader of another Alliance and can not be invited"
          end
        else
          #toDo invites for non-current members
          #create invite

          #create devise invite

          #send email

          #error
          success = false
          msg = "User #{email} is not currently a member this feature is a work in progress"
        end
      else
        #return error
        success = false
        msg = "You must be a signed in member of this alliance to invite someone"
      end
    else
      #return error
      success = false
      msg = "You must supply an email address"
    end
    return_data = {:success => success, :message => msg}
    render json: return_data
  end

  def redeem_invite
    email = params[:email]
    alliance = Alliance.find(params[:id])
    token = params[:token]

    if !user_signed_in?
      redirect_to root_url, :alert => "You must be signed in to do that"
    elsif current_user.email != email
      redirect_to root_url, :alert => "That email doesn't belong to you"
    else
      invite = AllianceInvite.valid_token?(email, token)
      if invite == nil
        redirect_to root_url, :alert => "Sorry that token was invalid"
      elsif params[:confirm] == 'true'
        #add the user the alliance
        invite.redeem
        redirect_to my_profile_path, :notice => "Success you've joined the #{alliance.name}."
      elsif params[:confirm] == 'false'
        invite.reject
        redirect_to my_profile_path, :notice => "Success you turned down the invitation to join  #{alliance.name}.
                                                 If you would like another one you will need to contact #{invite.invited_by.name}."
      else
        @invite = invite
      end
    end
  end

  private

  def sort_column
    %w[ranking RAC credit].include?(params[:sort]) ? params[:sort] : "ranking"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
