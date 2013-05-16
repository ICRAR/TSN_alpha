class NewsController < ApplicationController
  load_and_authorize_resource
  def show
    @news_item = News.published.where(:id => params[:id]).first
    render :show
  end
  def index
    @news_items = News.published.all
    render :index
  end
end