class GalaxiesController < ApplicationController
  authorize_resource :class => Galaxy
  helper :galaxies
  helper_method :sort_column, :sort_direction
  before_filter :check_boinc_id

  def check_boinc_id
    @boinc_id = params['boinc_id']
    unless @boinc_id.nil? || @boinc_id.to_i > 0
      redirect_to root_url, notice: 'Invalid boinc id'
    end
  end

  def index
    per_page = params[:per_page]
    per_page ||= 10
    page_num = params[:page]

    search_options = []
    search_options << "galaxy.name LIKE \"%#{Mysql2::Client.escape(params[:name])}%\"" if params[:name] != nil  && params[:name] != ''
    search_options << "galaxy.galaxy_type = \"#{Mysql2::Client.escape(params[:galaxy_type])}\"" if params[:galaxy_type] != nil && params[:galaxy_type] != ''
    search_options << "galaxy.ra_cent >= \"#{Mysql2::Client.escape(params[:ra_from])}\"" if params[:ra_from] != nil && params[:ra_from] != ''
    search_options << "galaxy.ra_cent <= \"#{Mysql2::Client.escape(params[:ra_to])}\"" if params[:ra_to] != nil && params[:ra_to] != ''
    search_options << "galaxy.dec_cent >= \"#{Mysql2::Client.escape(params[:dec_from])}\"" if params[:dec_from] != nil && params[:dec_from] != ''
    search_options << "galaxy.dec_cent <= \"#{Mysql2::Client.escape(params[:dec_to])}\"" if params[:dec_to] != nil && params[:dec_to] != ''
    search_options = search_options.join(' AND ')

    if @boinc_id == nil
      @galaxies = Galaxy.page(page_num).per(per_page).where(search_options).order(sort_column + " " + sort_direction)
    else
      @galaxies = Galaxy.page(page_num).per(per_page).find_by_user_id(@boinc_id).where(search_options).order(sort_column + " " + sort_direction)
    end

  end
  def show
    @galaxy = Galaxy.where(:galaxy_id => params[:id]).first
  end

  def send_report
    @galaxy = Galaxy.where(:galaxy_id => params[:id]).first
    if @galaxy.send_report(@boinc_id)
    #if false
      return_data = {:success => true}
    else
      return_data = {:success => false, :message => 'Too recent attempt'}
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

  private

  def sort_column
    %w[name galaxy_type redshift (dimension_x*dimension_y) ra_cent dec_cent (pixels_processed/pixel_count)].include?(params[:sort]) ? params[:sort] : "name"
  end


  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end



end