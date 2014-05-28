class TheSkyMap::ShipsController < TheSkyMap::ApplicationController

  respond_to :json

  def index

    @ships = TheSkyMap::Ship.for_index(current_user.profile.the_sky_map_player)


    render :json =>  @ships, :each_serializer => TheSkyMap::ShipIndexSerializer

  end

  def show
    respond_with TheSkyMap::Ship.for_show(current_user.profile.the_sky_map_player,params[:id])
  end

end
