class TheSkyMap::QuadrantsController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    if params[:ids]
      relation = TheSkyMap::Quadrant.where{id.in my{params[:ids]}}
    else
      relation = TheSkyMap::Quadrant
    end
    x_min = params[:x_min] || 0
    x_max = params[:x_max] || 2
    y_min = params[:y_min] || 0
    y_max = params[:y_max] || 2
    z_min = params[:z_min] || 0
    z_max = params[:z_max] || 2

    quadrants = relation.within_range(x_min,x_max,y_min,y_max,z_min,z_max).for_show(current_user.profile.the_sky_map_player)


    respond_with quadrants

  end

  def show
    respond_with TheSkyMap::Quadrant.for_show(current_user.profile.the_sky_map_player).find(params[:id])
  end

end
