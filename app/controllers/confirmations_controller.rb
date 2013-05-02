class ConfirmationsController < Devise::ConfirmationsController

  private

  def after_confirmation_path_for(resource_name, resource)
    url_for(:controller => 'profiles', :action => 'dashboard')
  end

end