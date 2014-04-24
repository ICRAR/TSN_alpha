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
    model_json = Sub::ShoutBoxSerializer.new(new_shout_box).to_json
    faye_broadcast "/messages/new/model", model_json
    respond_with new_shout_box
  end

  def update
    respond_with Sub::ShoutBox.update(params[:id], params[:entry])
  end

  def destroy
    respond_with Sub::ShoutBox.destroy(params[:id])
  end
end
