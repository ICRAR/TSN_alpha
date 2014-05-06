class Sub::ShoutBoxesController < Sub::ApplicationController

  respond_to :json

  def index
    respond_with Sub::ShoutBox.all
  end

  def show
    respond_with Sub::ShoutBox.find(params[:id])
  end

  def create
    if params[:shout_box]
      new_shout_box = Sub::ShoutBox.create(params[:shout_box])
    else
      new_shout_box = Sub::ShoutBox.create(params.slice(:msg))
    end
    PostToFaye.post_faye_model_delay new_shout_box, Sub::ShoutBoxSerializer
    respond_with new_shout_box
  end

  def update
    if params[:shout_box]
      new_shout_box = Sub::ShoutBox.update(params[:id], params[:shout_box])
    else
      new_shout_box = Sub::ShoutBox.update(params[:id],params.slice(:msg))
    end
    PostToFaye.post_faye_model_delay new_shout_box, Sub::ShoutBoxSerializer
    respond_with new_shout_box
  end

  def destroy
    destroyed = Sub::ShoutBox.destroy(params[:id])
    PostToFaye.remove_model_delay destroyed
    respond_with destroyed
  end
end
