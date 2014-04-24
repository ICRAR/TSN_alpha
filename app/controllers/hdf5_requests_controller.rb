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
    @request_new.galaxy_ids = @hdf5_request_galaxies.map {|i| i[:galaxy_id]}

    if @request_new.save
      @hdf5_request_galaxies = []
      save_galaxy_cart
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
      if @hdf5_request_galaxies.any? {|i| i[:galaxy_id] == @galaxy.id}
        flash.now[:alert] = "Sorry you've already added that galaxy."
        @request_new = Hdf5Request.new()
        render 'galaxies/show'
      else
        @hdf5_request_galaxies.push({:galaxy_id => @galaxy.id, :name => @galaxy.name})
        save_galaxy_cart
        redirect_to galaxies_path(request.query_parameters.except(:galaxy_id)), notice: "Success you added #{@galaxy.name} to your shopping cart"
      end
    else
      flash.now[:alert] = "Sorry that galaxy is not ready yet."
      @request_new = Hdf5Request.new()

      render 'galaxies/show'
    end
    #redirect_to galaxy page
  end
  def add_search
    load_galaxy_cart
    galaxies = Galaxy.search_options(params)
    galaxies_added_names = []
    galaxies.each do |galaxy|
      galaxy_name = "Galaxy: #{galaxy.name} (#{galaxy.id})"
      if [3,4].include? galaxy.status_id
        if @hdf5_request_galaxies.any? {|i| i[:galaxy_id] == galaxy.id}
          galaxies_added_names << "#{galaxy_name} was already in the cart"
        else
          @hdf5_request_galaxies.push({:galaxy_id => galaxy.id, :name => galaxy.name})
          galaxies_added_names << "#{galaxy_name} was added to the cart"
        end
      else
        galaxies_added_names << "#{galaxy_name} is not ready yet and wasn't added"
      end
    end
    save_galaxy_cart
    notice = "The following modifications were made to the your galaxy cart: <br /> \n"
    #notice << galaxies_added_names.join(" <br /> \n")
    redirect_to galaxies_path(request.query_parameters), notice: notice
  end
  def clear
    #clears the 'shopping cart'
    @hdf5_request_galaxies = []
    save_galaxy_cart
    redirect_to galaxies_path, notice: 'Success your Galaxy Request shopping cart has been cleared'
  end
  def remove
    load_galaxy_cart
    @hdf5_request_galaxies.reject!{|i| i[:galaxy_id] == params[:galaxy_id].to_i}
    save_galaxy_cart
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
