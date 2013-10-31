class Hdf5RequestsController < ApplicationController
  before_filter :authorise
  def authorise
    unless user_signed_in? && current_user.profile.is_science_user?
      raise(CanCan::AccessDenied,"Sorry you are not authorised to access this page")
    end
  end
  def index
    @requests = Hdf5Request.where{profile_id == my{current_user.profile.id}}.includes(:galaxy_requests).page(params[:page])
  end
  def new
    load_galaxy_cart
    @request_new = Hdf5Request.new()

  end
  def create
    load_galaxy_cart
    if params[:hdf5_request][:galaxy_id]
      galaxy = Galaxy.where(:galaxy_id => params[:hdf5_request][:galaxy_id]).first
      unless @hdf5_request_galaxies.any? {|i| i[:id] == galaxy.id}
        @hdf5_request_galaxies.push({:id => galaxy.id, :name => galaxy.name})
      end
    end

    @request_new = Hdf5Request.new(params[:hdf5_request].except(:galaxy_id))
    @request_new.profile_id = current_user.profile.id
    @request_new.galaxy_ids = @hdf5_request_galaxies.map {|i| i[:id]}

    if @request_new.save
      session[:hdf5_request_galaxies] = nil
      redirect_to hdf5_requests_path, notice: "Request Added, you will be emailed when the results are ready"
    else
      if params[:hdf5_request][:galaxy_id]
        @galaxy = galaxy
        @science_user = true
        render 'galaxies/show'
      else

        render 'hdf5_requests/new'
      end
    end
  end

  def show
    @request = Hdf5Request.where{hdf5_request_id == my{params[:id]}}.includes([:features,:layers]).first
    unless current_user.profile.id == @request.profile_id
      raise(CanCan::AccessDenied,"Sorry you are not authorised to access this page")
    end
    @page =  params[:page].to_i
    @page = 1 if @page == 0
    @galaxy_requests = Hdf5RequestGalaxy.where{hdf5_request_id == my{params[:id]}}.includes(:galaxy).page(@page).per(10)


  end

  def add
    load_galaxy_cart
    @science_user = true
    @galaxy = Galaxy.where{galaxy_id == my{params[:galaxy_id]}}.first || not_found
    if [3,4].include? @galaxy.status_id
      if @hdf5_request_galaxies.any? {|i| i[:id] == @galaxy.id}
        flash.now[:alert] = "Sorry you've all ready added that galaxy."
        @request_new = Hdf5Request.new()
        render 'galaxies/show'
      else
        @hdf5_request_galaxies.push({:id => @galaxy.id, :name => @galaxy.name})
        session[:hdf5_request_galaxies] = @hdf5_request_galaxies
        redirect_to galaxies_path(request.query_parameters.except(:galaxy_id)), notice: "Success you added #{@galaxy.name} to your shopping cat"
      end
    else
      flash.now[:alert] = "Sorry that galaxy is not ready yet."
      @request_new = Hdf5Request.new()

      render 'galaxies/show'
    end
    #redirect_to galaxy page
  end
  def clear
    #clears the 'shopping cart'
    session[:hdf5_request_galaxies] = nil
    redirect_to galaxies_path, notice: 'Success your Galaxy Request shopping cat has been cleared'
  end
  def remove
    load_galaxy_cart
    @hdf5_request_galaxies.reject!{|i| i[:id] == params[:galaxy_id].to_i}
    session[:hdf5_request_galaxies] = @hdf5_request_galaxies
    if  params[:current_galaxy_id]
      @science_user = true
      @galaxy = Galaxy.where{galaxy_id == my{params[:current_galaxy_id]}}.first || not_found
      flash.now[:notice] = "Success that Galaxy has been removed from your shopping cart"
      @request_new = Hdf5Request.new()
      render 'galaxies/show'
    elsif params[:return_to] == "galaxy_index"
      redirect_to galaxies_path(request.query_parameters.except(:galaxy_id)), notice: 'Success that Galaxy has been removed from your shopping cart'
    else
      @request_new = Hdf5Request.new()
      render 'hdf5_requests/new'
    end
  end

end
