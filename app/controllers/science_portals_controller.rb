class SciencePortalsController < ApplicationController
  authorize_resource
  def index
    @projects = SciencePortal.where{public == true}
    if user_signed_in?
      @private_projects = current_user.profile.members_science_portals
    end
  end

  def show
    @project = SciencePortal.where{id == my{params[:id]}}.includes([:pages,:science_links,:leaders]).first
    @project ||= SciencePortal.where{slug == my{params[:id]}}.includes([:pages,:science_links,:leaders]).first
    #@project ||= SciencePortal.where{name =~ my{"%#{params[:id]}%"}}.includes([:pages,:science_links,:leaders]).first
    if @project.nil?
      redirect_to root_url, notice: t("science_portals.controller.not_found")
      return
    end
    if user_signed_in?
      allowed = @project.check_access(current_user.profile.id)
    else
      allowed = @project.check_access(nil)
    end
    unless allowed == true
      redirect_to root_url, notice: t("science_portals.controller.not_authed")
      return
    end
    @leaders = @project.leaders.all
    @links = @project.science_links.all
    @pages = @project.pages.all
  end
end
