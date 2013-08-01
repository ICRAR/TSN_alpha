class SciencePortalsController < ApplicationController
  authorize_resource
  def index
    @projects = SciencePortal.where{public == true}
    if user_signed_in?
      @private_projects = current_user.profile.members_science_portals
    end
  end

  def show
    @project = SciencePortal.where{id == my{params[:id]}}.first
    if @project.nil?
      redirect_to root_url, notice: "Sorry we could not find that science project"
      return
    end
    if user_signed_in?
      allowed = @project.check_access(current_user.profile.id)
    else
      allowed = @project.check_access(nil)
    end
    unless allowed == true
      redirect_to root_url, notice: "Sorry you are not authorised to view that page"
      return
    end
    @leaders = @project.leaders.all
    @links = @project.science_links.all
  end
end
