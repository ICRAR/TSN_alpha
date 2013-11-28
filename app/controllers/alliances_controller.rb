class AlliancesController < ApplicationController
  # GET /alliances
  # GET /alliances.json
  authorize_resource
  helper_method :sort_column, :sort_direction

  def index
    per_page = [params[:per_page].to_i,1000].min
    per_page ||= 20
    @alliances = Alliance.for_leaderboard.page(params[:page]).per(per_page).order("`" + sort_column + "`" " " + sort_direction)
    @tags = Alliance.tag_counts.where("taggings.tags_count > 2")
  end

  # GET /alliances/1
  # GET /alliances/1.json
  def show
    @per_page = params[:per_page].to_i
    @per_page = 20 if @per_page == 0
    @page =  params[:page].to_i
    @page = 1 if @page == 0
    @alliance = Alliance.for_show(params[:id]) || not_found
    @members = AllianceMembers.page(@page).per(@per_page).for_alliance_show(params[:id])
    @total_members  = AllianceMembers.where(:alliance_id =>params[:id]).count
  end

  # GET /alliances/new
  # GET /alliances/new.json
  def new
    if !user_signed_in?
      redirect_to root_url, notice: 'You must be signed in too do that'
      return
    elsif current_user.profile.alliance
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    elsif current_user.profile.alliance_leader_id
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    end
    @alliance = Alliance.new
  end

  # GET /alliances/1/edit
  def edit
    @alliance = Alliance.find(params[:id], :include => 'members')
    authorize! :edit, @alliance
  end

  # POST /alliances
  # POST /alliances.json
  def create
    if !user_signed_in?
      redirect_to root_url, notice: 'You must be signed in too do that'
      return
    elsif current_user.profile.alliance
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    elsif current_user.profile.alliance_leader_id
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    end

    @alliance = Alliance.new(params[:alliance])

    if @alliance.is_boinc && !current_user.profile.is_pogs?
      @alliance.errors[:is_boinc] << "You must be POGS member to create a POGS alliance"
      render :new
    else

      @alliance.ranking = Alliance.calculate(:maximum,'ranking') + 1
      @alliance.credit = 0
      @alliance.leader = current_user.profile
      if @alliance.save
        current_user.profile.join_alliance @alliance
        @alliance.create_pogs_team if @alliance.is_boinc?

        redirect_to @alliance, notice: 'Alliance was successfully created.'
      else
        render :new
      end
    end

  end

  # PUT /alliances/1
  # PUT /alliances/1.json
  def update
    @alliance = Alliance.find(params[:id])
    if @alliance.is_boinc
      if @alliance.update_attributes(params[:alliance].slice(:tag_list))
        redirect_to @alliance, notice: 'Alliance was successfully updated.'
      else
        render :edit
      end
    else
      if params[:alliance][:leader_id] != @alliance.leader.id
        #change leader
        @alliance.leader = Profile.find(params[:alliance][:leader_id])
      end

      if @alliance.update_attributes(params[:alliance].slice(:tag_list,:invite_only, :desc))
        redirect_to @alliance, notice: 'Alliance was successfully updated.'
      else
        render :edit
      end
    end
  end

  # DELETE /alliances/1
  # DELETE /alliances/1.json
  def destroy
    @alliance = Alliance.find(params[:id])
    #@alliance.destroy
  end

  def join
    unless user_signed_in?
      redirect_to root_url, notice: 'Sorry you must be logged in to do that.'
      return
    end
    @alliance = Alliance.find(params[:id])
    #check that the current user irofile.sn't already part of an alliance
    if current_user.profile.alliance
      flash[:notice] = 'Sorry you can only be part of a single alliance'
    elsif @alliance.invite_only?
      flash[:alert] = "Sorry the #{@alliance.name} alliance is an invite only alliance. To join you must be invited by an existing member."
    elsif (@alliance.pogs_team_id > 0 && current_user.profile.general_stats_item.boinc_stats_item.nil?)
      flash[:alert] = "Sorry the #{@alliance.name} alliance is part of POGS. To join you must be also be a member of the POGS project."
    else
      current_user.profile.join_alliance @alliance
      flash[:notice] = "Welcome to the #{@alliance.name} Alliance"
    end

    redirect_to my_profile_path
  end

  def leave
    unless user_signed_in?
      redirect_to root_url, notice: 'Sorry you must be logged in to do that.'
      return
    end
    @alliance = current_user.profile.alliance

    #first check that the user has a current alliance membership
    if !@alliance
      flash[:notice] = 'Sorry you must join an alliance before you can leave an alliance'
    #check that user is not the alliance leader
    elsif current_user.profile.alliance_leader_id == @alliance.id
      flash[:notice] = 'Sorry the current leader cannot leave an alliance'
    else
      #remove user from alliance
      current_user.profile.leave_alliance
      flash[:notice] = "You have left the #{@alliance.name} alliance"
    end
    redirect_to my_profile_path
  end
  def search
    if params[:search]
      params[:sort] = "search"
      #@alliances = Alliance.search_by_name(params[:search]).includes(:leader).page(params[:page]).per(10)
      @alliances = Alliance.search params[:search], params[:page], 10
      #@tags = Alliance.tag_counts.where("tags.name LIKE ?", "%#{params[:search]}%")
      if @alliances.size == 0
        @tags = []
      else
        ids =  @alliances.map {|a| a.id}
        @tags = Alliance.where{id.in ids}.select(:id).tag_counts
      end
      render :index
    else
      redirect_to( alliances_path, :alert => "You did not enter a valid search query")
    end
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
        profile = user.profile if user && (user.invitation_accepted_at != nil || user.invitation_token == nil)
        if profile
          #check that the invited member is not a leader of another alliance
          if profile.alliance_leader == nil
            #create invite
            invite = AllianceInvite.new(:email => email)
            invite.alliance_id = alliance.id
            invite.invited_by_id =  current_user.profile.id
            invite.save

            #send email
            UserMailer.delay.alliance_invite(invite)
            #return success
            success = true
            msg = "Invite for #{alliance.name} sent to #{email}"
          else
            #error
            success = false
            msg = "User #{email} is a currently a leader of another Alliance and can not be invited"
          end
        else
          #create devise invite
          user = User.invite!({:email => email}, current_user)
          #create alliance invite with the same token
          invite = AllianceInvite.new(:email => email)
          invite.alliance_id = alliance.id
          invite.invited_by_id =  current_user.profile.id
          invite.save
          invite.token = user.invitation_token
          invite.save

          #error
          success = false
          msg = "Invite for #{Alliance.name} sent to #{email}"
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

  def tags
    tags = Alliance.tags_on(:tags).where("tags.name LIKE ?", "%#{params[:q]}%")
    tags_json = tags.map{|t| {:id => t.id, :name => t.name }}
    tags_json.unshift({:id => -1, :name => params[:q]})
    respond_to do |format|
      format.json { render :json => tags_json}
    end
  end

  #### all section are marked with ALLIANCE_DUP_CODE ###
  def mark_as_duplicate
    ## simply sends an email to contact form stating.
    ## only works for signed_in users

    if user_signed_in?
      @contact_form = ContactForm.new
      @contact_form.name = current_user.profile.name
      @contact_form.email = current_user.email
      @contact_form.profile_id = current_user.profile.id
      @contact_form.email_db = current_user.email
      @contact_form.name_db = current_user.profile.name

      @contact_form.message = "Alliance #{params[:id]} as been identified as a duplicate with #{params[:dup_id]}"
      @contact_form.request = request
      if @contact_form.valid?
        @contact_form.delay_send
        flash[:notice] = "Thank you for reporting. Your request will be check and the alliances marked as duplicates. :)"
      else
        flash[:notice] = "Something went wrong"
      end
      redirect_to root_url
    else
      redirect_to root_url, :notice => "You must be logged in to do that"
    end
  end
  ###########################################

  private

  def sort_column
    %w[ranking RAC credit].include?(params[:sort]) ? params[:sort] : "ranking"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
