class GalaxiesController < ApplicationController
  authorize_resource :class => Galaxy
  helper :galaxies
  helper_method :sort_column, :sort_direction
  before_filter :check_boinc_id

  def check_science_user
    if user_signed_in?
      current_user.profile.is_science_user?
    else
      return false
    end
  end

  def check_boinc_id
    @boinc_id = params['boinc_id']
    unless @boinc_id.nil? || @boinc_id.to_i > 0 || @boinc_id == 'all'
      redirect_to root_url, notice: 'Invalid boinc id'
    end
  end

  def index
    @science_user = check_science_user
    if @science_user
      load_galaxy_cart
      @request_new = Hdf5Request.new()

    end
    per_page = params[:per_page]
    per_page ||= 10
    page_num = params[:page]

    @galaxies = Galaxy.search_options(params)

    if (@boinc_id == nil) || (@boinc_id == 'all')
      @galaxies = @galaxies.page(page_num).per(per_page).order(sort_column + " " + sort_direction)
    else
      @galaxies = @galaxies.page(page_num).per(per_page).find_by_user_id(@boinc_id).where(search_options).order(sort_column("galaxy_id") + " " + sort_direction("desc"))
    end



  end
  def show
    @galaxy = Galaxy.where(:galaxy_id => params[:id]).first || not_found
    @science_user = check_science_user
    if @science_user
      load_galaxy_cart
      @request_new = Hdf5Request.new()
    end
  end

  def send_report
    @galaxy = Galaxy.where(:galaxy_id => params[:id]).first
    if @galaxy.send_report(@boinc_id)
    #if false
      return_data = {:success => true}
    else
      return_data = {:success => false, :message => 'Too many recent attempt'}
    end
    render json: return_data
  end


  def image
    require 'RMagick'
    galaxy = Galaxy.where(:galaxy_id => params[:id]).first

    scale = params['scale'] == 'true' ? true : false
    image = galaxy.color_image_user(@boinc_id,params[:colour],scale)

    file_name = "#{galaxy.name}_#{@boinc_id}_#{params[:colour]}.png"
    expires_in 10.minutes, :public => true
    send_data image, :type => "image/png", :disposition => 'inline', :filename => file_name
  end

  def tags
    @tags = GalaxyTag.search_tag params[:search]
  end

  private

  def sort_column(default = "name")
    %w[name galaxy_type redshift (dimension_x*dimension_y) ra_cent dec_cent (pixels_processed/pixel_count) galaxy_id].include?(params[:sort]) ? params[:sort] : default
  end


  def sort_direction(default = "asc")
    %w[asc desc].include?(params[:direction]) ? params[:direction] : default
  end



end