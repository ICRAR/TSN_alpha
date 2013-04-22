class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.json
  load_and_authorize_resource
  def index
    @profiles = Profile.for_leader_boards.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    if params[:id]
      @profile = Profile.find(params[:id], include: :trophies)
    elsif user_signed_in?
      @profile = current_user.profile
      params[:id] = current_user.profile.id

    else
      redirect_to root_url, notice: 'You must be logged in to view your own profile.'
      return
    end

    if user_signed_in? && (current_user.profile == @profile && @profile.new_profile_step < 2)
      if @profile.new_profile_step < 1
        respond_to do |format|
          format.html { render :new_profile_step_1}
          format.json { render json: @profile }
        end
      else
        respond_to do |format|
          format.html { render :new_profile_step_2}
          format.json { render json: @profile }
        end
      end
    else
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @profile }
      end
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
        @profile = current_user.profile

        boinc = BoincStatsItem.create_new_account(current_user.email,params['password'])
        if boinc.new_record?
          redirect_to @profile, alert: boinc.errors.full_messages.to_sentence
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
        redirect_to @profile, alert: 'Incorrect password.'
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
        @profile.general_stats_item.nereus_stats_item = nereus
        @profile.new_profile_step = [2,@profile.new_profile_step].max
        @profile.save
        redirect_to @profile, notice: 'Success accounts are now linked :).'
      else
        redirect_to @profile, notice: 'Sorry we could not find that ID.'
      end
    else
      redirect_to root_url, alert: 'You must be logged in to update your own profile.'
      return
    end
  end
  def search
    @profiles = Profile.search_by_name(params['search']).for_leader_boards.page(params[:page]).per(10)

    respond_to do |format|
      format.html { render :index} # index.html.erb
      format.json { render json: @profiles }
    end
  end
end
