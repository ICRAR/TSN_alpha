class GalaxiesController < ApplicationController
  authorize_resource :class => Galaxy
  helper :galaxies
  helper_method :sort_column, :sort_direction

  def index
    @boinc_id = params['boinc_id']
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
    @boinc_id = params['boinc_id']
    @galaxy = Galaxy.where(:galaxy_id => params[:id]).first
  end

  private

  def sort_column
    %w[name galaxy_type redshift (dimension_x*dimension_y) ra_cent dec_cent (pixels_processed/pixel_count)].include?(params[:sort]) ? params[:sort] : "name"
  end


  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end