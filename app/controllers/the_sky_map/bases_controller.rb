class TheSkyMap::BasesController < TheSkyMap::ApplicationController
  respond_to :json

  def index

    @bases = TheSkyMap::Base.for_index(current_user.profile.the_sky_map_player)


    render :json =>  @bases, :each_serializer => TheSkyMap::BaseIndexSerializer

  end

  def show
    respond_with TheSkyMap::Base.for_show(current_user.profile.the_sky_map_player,params[:id])
  end

end
