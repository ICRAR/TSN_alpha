class TheSkyMap::QuadrantsController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    if params[:ids]
      relation = TheSkyMap::Quadrant.where{id.in my{params[:ids]}}
    else
      x_min = params[:x_min] || 0
      x_max = params[:x_max] || 2
      y_min = params[:y_min] || 0
      y_max = params[:y_max] || 2
      relation = TheSkyMap::Quadrant.within_range(x_min,x_max,y_min,y_max,current_map_id)
    end

    quadrants = relation.for_show(current_player_object)


    respond_with quadrants

  end

  def show
    respond_with TheSkyMap::Quadrant.for_show(current_player_object).find(params[:id])
  end

end
