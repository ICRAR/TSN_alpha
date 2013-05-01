class ApplicationController < ActionController::Base
  protect_from_forgery :except => :check_auth

  if Rails.env.development?  && false
    Rack::MiniProfiler.authorize_request
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    #redirect_to main_app.root_path
    redirect_to :controller => "/pages", :action => "show", :slug => "denied"
  end

  #simple json check authentication for current user for phpbb integration
  def check_auth
    if current_user
      return_data = {:username => current_user.username,
                     :email => current_user.email,
                     :admin => current_user.is_admin?,
                     :authenticated => true
      }
    else
      return_data = {:authenticated => false}
    end
    logger.debug return_data

    render json: return_data
  end
end
