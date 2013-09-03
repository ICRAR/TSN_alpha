class ApplicationController < ActionController::Base
  protect_from_forgery :except => [:check_auth, :ping, :facebook_channel]
  helper :json_api
  require 'act_as_taggable_on'

  before_filter :check_announcement, :except => [:check_auth,:ping,:send_report,:send_cert, :facebook_channel]
  newrelic_ignore :only => [:check_auth,:ping]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found
    redirect_to :controller => "/pages", :action => "show", :slug => "404"
  end

  def check_announcement
    if user_signed_in?
      @announcement = News.announcement(current_user.profile.announcement_time)

      ::NewRelic::Agent.add_custom_parameters(:profile_id => current_user.profile.id)
    end

  end

  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  def default_url_options(options={})
    #logger.debug "default_url_options is passed options: #{options.inspect}\n"
    options = {}
    options[:locale] = I18n.locale
    options[:format] = :json if params[:format] == "json"
    options
  end


  def after_sign_in_path_for(resource)
    my_profile_path
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

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def facebook_channel
    expires_in 1.day, :public => true
    render text: '<script src="//connect.facebook.net/en_US/all.js"></script>'
  end
end
