class TheSkyMap::MiniQuadrantsController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    if params[:ids]
      relation = TheSkyMap::Quadrant.where{id.in my{params[:ids]}}
    else
      relation = TheSkyMap::Quadrant
    end
    quadrants = relation.where{z == 1}.for_show_mini(current_user.profile.the_sky_map_player)


    render :json =>  quadrants, :each_serializer => TheSkyMap::MiniQuadrantSerializer

  end

  def show
    quadrant =  TheSkyMap::Quadrant.for_show_mini(current_user.profile.the_sky_map_player).find(params[:id])
    render :json =>  quadrant, :serializer => TheSkyMap::MiniQuadrantSerializer
  end

end
