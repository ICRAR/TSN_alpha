class TheSkyMap::BasesController < TheSkyMap::ApplicationController
  respond_to :json

  def index
    page = params[:page].to_i || 1
    per_page = params[:per_page].to_i || 10
    @bases = TheSkyMap::Base.page(page).per(per_page).for_index(current_user.profile.the_sky_map_player)
    if params[:ids]
      @bases = @bases.where{id.in my{params[:ids]}}
    end
    render :json =>  @bases, :each_serializer => TheSkyMap::BaseIndexSerializer, meta: pagination_meta(@bases)

  end

  def show
    respond_with TheSkyMap::Base.for_show(current_user.profile.the_sky_map_player,params[:id])
  end

  def game_actions_available
    @base = TheSkyMap::Base.for_show(current_user.profile.the_sky_map_player,params[:id])
    render :json =>  @base, serializer: TheSkyMap::ActionableSerializer, root: 'base'

  end
end
