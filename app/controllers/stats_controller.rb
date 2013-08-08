class StatsController < ApplicationController
  #authorize_resource
  def index
    @stats = SiteStat.for_feed
  end
end