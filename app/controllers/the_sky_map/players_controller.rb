class TheSkyMap::PlayersController < TheSkyMap::ApplicationController
  respond_to :json

  def index

    @players = TheSkyMap::Player.for_index(current_user.profile.the_sky_map_player)


    render :json =>  @players, :each_serializer => TheSkyMap::PlayerIndexSerializer

  end

  def show
    respond_with TheSkyMap::Player.for_show(current_user.profile.the_sky_map_player,params[:id])
  end

end
