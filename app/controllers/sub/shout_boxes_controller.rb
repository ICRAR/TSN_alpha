class Sub::ShoutBoxesController < Sub::ApplicationController

  respond_to :json

  def index
    respond_with Sub::ShoutBox.all
  end

  def show
    respond_with Sub::ShoutBox.find(params[:id])
  end

  def create
    new_shout_box = Sub::ShoutBox.create(params.slice(:msg))
    post_faye_model new_shout_box, Sub::ShoutBoxSerializer
    respond_with new_shout_box
  end

  def update
    respond_with Sub::ShoutBox.update(params[:id], params[:entry])
  end

  def destroy
    respond_with Sub::ShoutBox.destroy(params[:id])
  end
end
