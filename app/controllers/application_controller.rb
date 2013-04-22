class ApplicationController < ActionController::Base
  protect_from_forgery

  if Rails.env.development?  && false
    Rack::MiniProfiler.authorize_request
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    #redirect_to main_app.root_path
    redirect_to :controller => "/pages", :action => "show", :slug => "denied"
  end
end
