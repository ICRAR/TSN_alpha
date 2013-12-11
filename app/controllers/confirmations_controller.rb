class ConfirmationsController < Devise::ConfirmationsController

  private

  def after_confirmation_path_for(resource_name, resource)
    flash[:page] = "/confirmation/success"
    url_for(:controller => 'profiles', :action => 'dashboard')
  end

end