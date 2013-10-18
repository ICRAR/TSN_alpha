class StatsController < ApplicationController
  #authorize_resource
  skip_before_filter :check_announcement
  skip_before_filter :store_location
  def index
    @stats = SiteStat.for_feed
  end
  def activities
    if params[:page].to_i == 1
      @activities = @activity = Activity.page(1).per(10).order{id.desc}
    else
      @activities = @activity = Activity.page(params[:page].to_i-1).padding(10).per(25).order{id.desc}
    end
    @next_page = @activities.next_page.nil? ? 0 : (params[:page].to_i)
    render layout: false, formats: :js
  end
end