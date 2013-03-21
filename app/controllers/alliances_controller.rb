class AlliancesController < ApplicationController
  # GET /alliances
  # GET /alliances.json
  load_and_authorize_resource
  def index
    @alliances = Alliance.ranked.includes(:leader).page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alliances }
    end
  end

  # GET /alliances/1
  # GET /alliances/1.json
  def show
    @alliance = Alliance.for_show(params[:id])
    @members = Profile.for_alliance(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alliance }
    end
  end

  # GET /alliances/new
  # GET /alliances/new.json
  def new
    if current_user.profile.alliance
      redirect_to my_profile_url, notice: 'Sorry you can not create a new alliance when you are part of an existing alliance'
      return
    end
    @alliance = Alliance.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alliance }
    end
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
    respond_to do |format|
      if @alliance.save
        @alliance.members << current_user.profile

        @alliance.leader = current_user.profile

        format.html { redirect_to @alliance, notice: 'Alliance was successfully created.' }
        format.json { render json: @alliance, status: :created, location: @alliance }
      else
        format.html { render action: "new" }
        format.json { render json: @alliance.errors, status: :unprocessable_entity }
      end
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

    respond_to do |format|
      if @alliance.update_attributes(params[:alliance].except('leader'))
        format.html { redirect_to @alliance, notice: 'Alliance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @alliance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alliances/1
  # DELETE /alliances/1.json
  def destroy
    @alliance = Alliance.find(params[:id])
    @alliance.destroy

    respond_to do |format|
      format.html { redirect_to alliances_url }
      format.json { head :no_content }
    end
  end

  def join
      @alliance = Alliance.find(params[:id])
      #check that the current user isn't already part of an alliance
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
    current_user.profile.alliance = nil
    current_user.profile.save
    flash[:notice] = "You have left the #{@alliance.name} alliance"
    end
    redirect_to my_profile_path
  end
  def search
    @alliances = Alliance.search_by_name(params[:search]).includes(:leader).page(params[:page]).per(10)

    respond_to do |format|
      format.html { render :index }
      format.js { @alliances }
    end
  end
end
