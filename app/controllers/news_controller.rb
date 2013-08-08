class NewsController < ApplicationController
  authorize_resource
  def show
    @news_item = News.published.where(:id => params[:id]).first
    if @new_item.nil?
      redirect_to root_url, notice: "Sorry we couldn't find that item"
    else
      render :show
    end
  end
  def index
    @news = News.published.all
    render :index
  end
  def dismiss
    if user_signed_in?
      profile = current_user.profile
      news = News.find(params[:id])
      profile.announcement_time = news.published_time
      profile.save
      @announcement = News.announcement(profile.announcement_time)
      render :dismiss, :layout => false
    else
      redirect_to root_url, notice: 'You must be logged in to do that.'
    end
  end

end