class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.json
  authorize_resource
  helper_method :sort_column, :sort_direction
  def index
    per_page = params[:per_page]
    per_page ||= 30
    if (params[:rank] && !params[:page] )
      rank = [[params[:rank].to_i,per_page/2+1].max,Profile.for_leader_boards.count].min
      page_num = (rank-per_page/2) / per_page + 1
      page_padding = (rank-per_page/2) % per_page-1
    else
      page_num = params[:page]
      page_padding = 0;
    end
    @profiles = Profile.for_leader_boards.page(page_num).per(per_page).padding(page_padding).order(sort_column + " " + sort_direction + " NULLS LAST")

  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @profile = Profile.for_show(params[:id])
  end

  def compare
    @profile1 = Profile.for_show(params[:id1])
    @profile2 = Profile.for_show(params[:id2])
  end

  def dashboard
    if user_signed_in?
      @profile = current_user.profile
    else
      redirect_to root_url, notice: 'You must be logged in to view your own profile.'
      return
    end

    @top_profiles = Profile.for_leader_boards_small.order("rank asc").limit(5)
    @top_alliances = Alliance.for_leaderboard_small.order('ranking asc').limit(5)

    case @profile.new_profile_step
      when 0
        @profile.nickname = @profile.user.username
        respond_to do |format|
          format.html { render :new_profile_step_1}
          format.json { render :dashboard }
        end
      when 1
        respond_to do |format|
          format.html { render :new_profile_step_2}
          format.json { render :dashboard }
        end
      when 2
        @profile.new_profile_step = 3
        @profile.save
        respond_to do |format|
          format.html { render :new_profile_step_3}
          format.json { render :dashboard }
        end
      else
        render :action => "dashboard"
    end
  end

  def trophies
    @profile = Profile.find(params[:id])
    @trophies = @profile.trophies.order("profiles_trophies.created_at DESC, trophies.credits DESC")
  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    @profile = Profile.new
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

    if @profile.save
      redirect_to @profile, notice: 'Profile was successfully created.'
    else
      render :new
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @profile = Profile.find(params[:id])


    if @profile.update_attributes(params[:profile])
      @profile.new_profile_step = [1,@profile.new_profile_step].max
      @profile.save
      redirect_to @profile, notice: 'Profile was successfully updated.'
    else
      render action: "edit"
    end

  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
 # def destroy
 #   @profile = Profile.find(params[:id])
 #   @profile.destroy
 #
 #   redirect_to profiles_url
 # end
  def update_boinc_id
    if user_signed_in?
      @profile = current_user.profile
      boinc = BoincStatsItem.find_by_boinc_auth(params['boinc_user'],params['boinc_password'])
      if boinc.new_record?
        redirect_to @profile, alert: boinc.errors.full_messages.to_sentence
      else
        @profile.general_stats_item.boinc_stats_item = boinc
        @profile.new_profile_step = [3,@profile.new_profile_step].max
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
          @profile.new_profile_step = [3,@profile.new_profile_step].max
          @profile.save
          #todo create boinc welcome page
          render :boinc_welcome
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
          @profile.new_profile_step = [3,@profile.new_profile_step].max
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
        redirect_to my_profile_path, notice: 'Updated.'

      else
        redirect_to my_profile_path, notice: 'Sorry we could not find your nereus account.'

      end
    else
      redirect_to root_url, alert: 'You must be logged in to do that.'

      return
    end
  end
  def resume_nereus
    if user_signed_in?
      @profile = current_user.profile
      nereus = current_user.profile.general_stats_item.nereus_stats_item
      if nereus != nil
        nereus.resume
        redirect_to my_profile_path, notice: 'Updated.'

      else
        redirect_to my_profile_path, notice: 'Sorry we could not find your nereus account.'

      end
    else
      redirect_to root_url, alert: 'You must be logged in to do that.'

      return
    end
  end
  def search
    @profiles = Kaminari.paginate_array(Profile.for_leader_boards.search(params['search'])).page(params[:page]).per(10)

    render :index
  end

  private

  def sort_column
    %w[rank rac credits].include?(params[:sort]) ? params[:sort] : "rank"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
