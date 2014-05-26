class TheSkyMap::ShipsController < TheSkyMap::ApplicationController

  respond_to :json

  def index

    quadrants = TheSkyMap::Ship.for_index(current_user.profile.the_sky_map_player)


    respond_with quadrants

  end

  def show
    respond_with TheSkyMap::Ship.for_show(current_user.profile.the_sky_map_player,params[:id])
  end

end
