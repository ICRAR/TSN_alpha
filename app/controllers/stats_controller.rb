class StatsController < ApplicationController
  #authorize_resource
  skip_before_filter :check_announcement
  skip_before_filter :store_location
  def index
    @stats = SiteStat.for_feed
  end
  def activities
    @activities = @activity = Activity.page(params[:page]).order{id.desc}
    render layout: false, formats: :js
  end
end