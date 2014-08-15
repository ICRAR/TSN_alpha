class TheSkyMap::PlayersController < TheSkyMap::ApplicationController
  respond_to :json

  def index

    page = params[:page].to_i || 1
    per_page = params[:per_page].to_i || 10
    @players = TheSkyMap::Player.page(page).per(per_page).for_index(current_user.profile.the_sky_map_player)
    render :json =>  @players, :each_serializer => TheSkyMap::PlayerIndexSerializer, meta: pagination_meta(@players)

  end

  def show
    respond_with TheSkyMap::Player.for_show(current_user.profile.the_sky_map_player,params[:id])
  end

end
