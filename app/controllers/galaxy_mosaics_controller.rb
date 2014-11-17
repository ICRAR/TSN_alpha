class GalaxyMosaicsController < ApplicationController
  authorize_resource

  def index
    per_page = [params[:per_page].to_i,1000].min
    per_page ||= 20
    @mosaics = GalaxyMosaic.for_show.page(params[:page]).per(per_page)
  end

  def show
    if user_signed_in? && !current_user.profile.general_stats_item.boinc_stats_item.nil?
      @boinc_id = current_user.profile.general_stats_item.boinc_stats_item.boinc_id
    end
    @mosaic = GalaxyMosaic.for_show.find(params[:id])
  end
end