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

    respond_to do |format|
      format.html # show.html.erb
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

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
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
      @profile.general_stats_item.boinc_stats_item = BoincStatsItem.find_by_boinc_auth(params['boinc_user'],params['boinc_password'])
      redirect_to @profile
    else
      redirect_to root_url, notice: 'You must be logged in to update your own profile.'
      return
    end
  end
  def update_nereus_id
    if user_signed_in?
      @profile = current_user.profile
      nereus = NereusStatsItem.where(:nereus_id => params['nereus_id']).try(:first)
      if nereus != nil
        @profile.general_stats_item.nereus_stats_item = nereus
        redirect_to @profile, notice: 'Success accounts are now linked :).'
      else
        redirect_to @profile, notice: 'Sorry we could not find that ID.'
      end
    else
      redirect_to root_url, notice: 'You must be logged in to update your own profile.'
      return
    end
  end
end
