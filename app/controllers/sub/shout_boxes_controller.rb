class Sub::ShoutBoxesController < ApplicationController

  respond_to :json

  def index
    respond_with Sub::ShoutBox.all
  end

  def show
    respond_with Sub::ShoutBox.find(params[:id])
  end

  def create
    respond_with Sub::ShoutBox.create(params[:entry])
  end

  def update
    respond_with Sub::ShoutBox.update(params[:id], params[:entry])
  end

  def destroy
    respond_with Sub::ShoutBox.destroy(params[:id])
  end
end
