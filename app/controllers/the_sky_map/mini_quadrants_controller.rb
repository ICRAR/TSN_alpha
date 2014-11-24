class TheSkyMap::MiniQuadrantsController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    if params[:ids]
      relation = TheSkyMap::Quadrant.where{id.in my{params[:ids]}}
    else
      relation = TheSkyMap::Quadrant
    end
    quadrants = relation.where{game_map_id == my{current_map_id}}.for_show_mini(current_player_object)


    render :json =>  quadrants, :each_serializer => TheSkyMap::MiniQuadrantSerializer

  end

  def show
    quadrant =  TheSkyMap::Quadrant.for_show_mini(current_player_object).find(params[:id])
    render :json =>  quadrant, :serializer => TheSkyMap::MiniQuadrantSerializer
  end

end
