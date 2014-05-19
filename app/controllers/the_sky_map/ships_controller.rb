class TheSkyMap::ShipsController < TheSkyMap::ApplicationController

  respond_to :json

  def index

    quadrants = TheSkyMap::Ship.for_index(current_user.profile.the_sky_map_player.id)


    respond_with quadrants

  end

  def show
    respond_with TheSkyMap::Ship.for_show(params[:id])
  end

end
