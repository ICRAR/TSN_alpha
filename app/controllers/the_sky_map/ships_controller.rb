class TheSkyMap::ShipsController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    page = params[:page].to_i || 1
    per_page = params[:per_page].to_i || 10
    @ships = TheSkyMap::Ship.page(page).per(per_page).for_index(current_user.profile.the_sky_map_player)
    render :json =>  @ships, :each_serializer => TheSkyMap::ShipIndexSerializer, meta: pagination_meta(@ships)

  end

  def show
    respond_with TheSkyMap::Ship.for_show(current_user.profile.the_sky_map_player,params[:id])
  end



end
