class TheSkyMap::ShoutBoxesController < TheSkyMap::ApplicationController

  respond_to :json

  def index
    respond_with TheSkyMap::ShoutBox.all
  end

  def show
    respond_with TheSkyMap::ShoutBox.find(params[:id])
  end

  def create
    if params[:shout_box]
      new_shout_box = TheSkyMap::ShoutBox.create(params[:shout_box])
    else
      new_shout_box = TheSkyMap::ShoutBox.create(params.slice(:msg))
    end
    PostToFaye.post_faye_model_delay new_shout_box, TheSkyMap::ShoutBoxSerializer
    respond_with new_shout_box
  end

  def update
    if params[:shout_box]
      new_shout_box = TheSkyMap::ShoutBox.update(params[:id], params[:shout_box])
    else
      new_shout_box = TheSkyMap::ShoutBox.update(params[:id],params.slice(:msg))
    end
    PostToFaye.post_faye_model_delay new_shout_box, TheSkyMap::ShoutBoxSerializer
    respond_with new_shout_box
  end

  def destroy
    destroyed = TheSkyMap::ShoutBox.destroy(params[:id])
    PostToFaye.remove_model_delay destroyed
    respond_with destroyed
  end
end
