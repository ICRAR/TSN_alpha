class Hdf5RequestsController < ApplicationController
  before_filter :authorise
  def authorise
    unless user_signed_in? && current_user.profile.is_science_user?
      raise(CanCan::AccessDenied,"Sorry you are not authorised to access this page")
    end
  end
  def index
    @requests = Hdf5Request.where{profile_id == my{current_user.profile.id}}.includes(:galaxy).page(params[:page])
  end
  def create
    @request_new = Hdf5Request.new(params[:hdf5_request])
    @request_new.profile_id = current_user.profile.id
    if @request_new.save
      redirect_to hdf5_requests_path, notice: "Request Added, you will be emailed when the results are ready"
    else
      @galaxy = Galaxy.where(:galaxy_id => params[:hdf5_request][:galaxy_id]).first
      @science_user = true
      render 'galaxies/show'
    end
  end
  def show
    @request = Hdf5Request.find params[:id]
    unless current_user.profile.id == @request.profile_id
      raise(CanCan::AccessDenied,"Sorry you are not authorised to access this page")
    end
  end
end
