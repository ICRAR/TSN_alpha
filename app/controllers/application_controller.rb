class ApplicationController < ActionController::Base
  protect_from_forgery :except => [:check_auth, :ping, :facebook_channel]
  helper :json_api
  require 'act_as_taggable_on'

  ## TheSkyNet utilises special event days
  before_filter :special_days, :except => [:check_auth,:ping,:send_report,:send_cert, :facebook_channel]
  def special_days
    @special_days = SpecialDay.active_days(params)
  end
  before_filter :check_announcement, :except => [:check_auth,:ping,:send_report,:send_cert, :facebook_channel]
  def check_announcement
    if user_signed_in?
      check_time = current_user.profile.announcement_time
      check_time ||= current_user.joined_at
      @announcement = News.announcement(check_time)

      ::NewRelic::Agent.add_custom_parameters(:profile_id => current_user.profile.id)
    end

  end
  newrelic_ignore :only => [:check_auth,:ping]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  def record_not_found
    redirect_to :controller => "/pages", :action => "show", :slug => "404"
  end



  before_filter :set_locale
  def set_locale
    I18n.locale = I18n.default_locale
    unless @special_days.nil? || @special_days.first_locale.nil?
      I18n.locale = @special_days.first_locale
    end
    I18n.locale = params[:locale] if params[:locale]


  end
  def default_url_options(options={})
    #logger.debug "default_url_options is passed options: #{options.inspect}\n"
    options = {}
    options[:locale] = I18n.locale
    options[:format] = :json if params[:format] == "json"
    options = options.merge @special_days.active_url_code(params) unless @special_days.nil?
    options
  end

  before_filter :store_location

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    # this works a white listed regex system
    allowed_paths = [/^\/profile/,/^\/alliance/,/^\/admin/,/^\/trophies/,/^\/misc/,/^\/news/]
    skip_paths = [/^\/pages\/denied/, /^\/users/,  /^\/social/, ]
    #only store html requests and requests that match at least one of allowed_paths
    if (request.format == 'text/html') && allowed_paths.map{|r| !request.fullpath.index(r).nil?}.include?(true)
      session[:previous_url] = request.fullpath
    elsif params['prev_path'] == 'forum'       #or if the users just came from the forum redirect them back after
      session[:previous_url] = APP_CONFIG['forum_url']
    elsif request.format == 'text/html' && !(skip_paths.map{|r| !request.fullpath.index(r).nil?}.include?(true)) # reset on pages that are not the sign in page
      session[:previous_url] = nil
    end

  end

  def after_sign_in_path_for(resource = nil)
    session[:previous_url] || my_profile_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    #redirect_to main_app.root_path
    redirect_to :controller => "/pages", :action => "show", :slug => "denied"
  end

  #simple json check authentication for current user for phpbb integration
  def check_auth
    if current_user
      return_data = {:username => current_user.username_forum,
                     :email => current_user.email,
                     :admin => current_user.is_admin?,
                     :authenticated => true
      }
    else
      return_data = {:authenticated => false}
    end
    #logger.debug return_data

    render json: return_data
    return
  end

  def ping
    raise 'database error' unless ActiveRecord::Base.connected?
    render json:{:status => 'ok'}
  end


  def facebook_channel
    expires_in 1.day, :public => true
    render text: '<script src="//connect.facebook.net/en_US/all.js"></script>'
  end

  def load_galaxy_cart
    @hdf5_request_galaxies = session[:hdf5_request_galaxies]
    @hdf5_request_galaxies ||= []
  end

  private

  def signed_in
    redirect_to( root_url, notice: 'Sorry could must be signed in to do that') unless user_signed_in?
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end

  def user_is_admin?
    user_signed_in? && current_user.is_admin?
  end
  helper_method :user_is_admin?
end
