class TheSkyMap::PlayersController < TheSkyMap::ApplicationController
  respond_to :json

  def index
    if params[:ids]
      relation = TheSkyMap::Player.where{id.in my{params[:ids]}}
    else
      relation = TheSkyMap::Player
    end
    page = params[:page].to_i || 1
    per_page = params[:per_page].to_i || 10
    @players = relation.page(page).per(per_page).for_index(current_player_object)
    render :json =>  @players, :each_serializer => TheSkyMap::PlayerIndexSerializer, meta: pagination_meta(@players)

  end

  def show
    respond_with TheSkyMap::Player.for_show(current_player_object,params[:id])
  end

end
