class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.json
  authorize_resource
  helper_method :sort_column, :sort_direction
  def index
    page_per = 30
    if (params[:rank] && !params[:page] )
      rank = [[params[:rank].to_i,page_per/2+1].max,Profile.for_leader_boards.count].min
      page_num = (rank-page_per/2) / page_per + 1
      page_padding = (rank-page_per/2) % page_per-1
    else
      page_num = params[:page]
      page_padding = 0;
    end
    @profiles = Profile.for_leader_boards.page(page_num).per(page_per).padding(page_padding).order(sort_column + " " + sort_direction + " NULLS LAST")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @profile = Profile.for_show(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  def dashboard
    if user_signed_in?
      @profile = current_user.profile
    else
      redirect_to root_url, notice: 'You must be logged in to view your own profile.'
      return
    end

    @top_profiles = Profile.for_leader_boards.order("rank asc").limit(5)
    @top_alliances = Alliance.for_leaderboard.order('ranking asc').limit(5)

    if @profile.new_profile_step < 2
      if @profile.new_profile_step < 1
        @profile.nickname = @profile.user.username
        respond_to do |format|
          format.html { render :new_profile_step_1}
          format.json { render json: @profile.for_json_full }
        end
      else
        respond_to do |format|
          format.html { render :new_profile_step_2}
          format.json { render json: @profile.for_json_full }
        end
      end
    else
      respond_to do |format|
        format.html { render :dashboard}
        format.json { render json: @profile.for_json_full }
      end
    end
  end

  def trophies
    @profile = Profile.includes(:trophies).find(params[:id])
    respond_to do |format|
      format.html # trophies.html.erb
      format.json { render json: @profile }
    end


  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    if user_signed_in?
      @profile = current_user.profile

    else
      redirect_to root_url, notice: 'You must be logged in to update your own profile.'
      return
    end
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render json: @profile, status: :created, location: @profile }
      else
        format.html { render action: "new" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @profile = Profile.find(params[:id])


    if @profile.update_attributes(params[:profile])
      @profile.new_profile_step = [1,@profile.new_profile_step].max
      @profile.save
      respond_to do |format|
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.json { head :no_content }
    end
  end
  def update_boinc_id
    if user_signed_in?
      @profile = current_user.profile
      boinc = BoincStatsItem.find_by_boinc_auth(params['boinc_user'],params['boinc_password'])
      if boinc.new_record?
        redirect_to @profile, alert: boinc.errors.full_messages.to_sentence
      else
        @profile.general_stats_item.boinc_stats_item = boinc
        @profile.new_profile_step = [2,@profile.new_profile_step].max
        @profile.save
        redirect_to @profile, notice: 'Success your account has been joined'
      end

    else
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
      return
    end
  end
  def create_boinc_id
    if user_signed_in?
      @profile = current_user.profile
      #check that password is correct
      if  current_user.valid_password?(params['password'])
        boinc = BoincStatsItem.create_new_account(current_user.email,params['password'])
        if boinc.new_record?
          redirect_to my_profile_path, alert: boinc.errors.full_messages.to_sentence
        else
          @profile.general_stats_item.boinc_stats_item = boinc
          @profile.new_profile_step = [2,@profile.new_profile_step].max
          @profile.save
          #todo create boinc welcome page
          respond_to do |format|
            format.html { render :boinc_welcome} # index.html.erb
            format.json { render json: @profiles }
          end
        end
      else
        redirect_to my_profile_path, alert: 'Incorrect password.'
        return
      end
    else
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
      return
    end
  end
  def update_nereus_id
    if user_signed_in?
      @profile = current_user.profile
      nereus = NereusStatsItem.where(:nereus_id => params['nereus_id']).try(:first)
      if nereus != nil
        if nereus.general_stats_item != nil
          redirect_to my_profile_path, notice: 'Sorry that account has all ready been linked, if you believe this is incorrect please contact us'
        else
          @profile.general_stats_item.nereus_stats_item = nereus
          @profile.new_profile_step = [2,@profile.new_profile_step].max
          @profile.save
          redirect_to my_profile_path, notice: 'Success accounts are now linked :).'
        end

      else
        redirect_to my_profile_path, notice: 'Sorry we could not find that ID.'
      end
    else
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
      return
    end
  end
  def update_nereus_settings
    if user_signed_in?
      @profile = current_user.profile
      nereus = current_user.profile.general_stats_item.nereus_stats_item
      if nereus != nil
        in_mbytes = params['nereus_stats_item']['network_limit_mb'].to_i
        nereus.network_limit = in_mbytes *1024*1024
        nereus.save
        redirect_to my_profile_path, notice: 'Updated.'
      else
        redirect_to my_profile_path, notice: 'Sorry we could not find your nereus account.'
      end
    else
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
      return
    end
  end
  def pause_nereus
    if user_signed_in?
      @profile = current_user.profile
      nereus = current_user.profile.general_stats_item.nereus_stats_item
      if nereus != nil
        nereus.pause
        respond_to do |format|
          format.html { redirect_to my_profile_path, notice: 'Updated.'}
          format.json { render json: {notice: 'Updated.',profile: @profile.for_json_full} }
        end

      else
        respond_to do |format|
          format.html { redirect_to my_profile_path, notice: 'Sorry we could not find your nereus account.'}
          format.json { render json: {notice: 'Sorry we could not find your nereus account.'} }
        end

      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: 'You must be logged in to do that.'}
        format.json { render json: {alert: 'You must be logged in to do that.'} }
      end

      return
    end
  end
  def resume_nereus
    if user_signed_in?
      @profile = current_user.profile
      nereus = current_user.profile.general_stats_item.nereus_stats_item
      if nereus != nil
        nereus.resume
        respond_to do |format|
          format.html { redirect_to my_profile_path, notice: 'Updated.'}
          format.json { render json: {notice: 'Updated.',profile: @profile.for_json_full} }
        end

      else
        respond_to do |format|
          format.html { redirect_to my_profile_path, notice: 'Sorry we could not find your nereus account.'}
          format.json { render json: {notice: 'Sorry we could not find your nereus account.'} }
        end

      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: 'You must be logged in to do that.'}
        format.json { render json: {alert: 'You must be logged in to do that.'} }
      end

      return
    end
  end
  def search
    @profiles = Kaminari.paginate_array(Profile.for_leader_boards.search(params['search'])).page(params[:page]).per(10)

    respond_to do |format|
      format.html { render :index} # index.html.erb
      format.json { render json: @profiles }
    end
  end

  private

  def sort_column
    %w[rank rac credits].include?(params[:sort]) ? params[:sort] : "rank"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
