class NewsController < ApplicationController
  authorize_resource
  def show
    @news_item = News.published.where(:id => params[:id]).first
    if @news_item.nil?
      redirect_to root_url, notice: "Sorry we couldn't find that item"
    else
      #if user_signed_in?
      #  @comment = Comment.new(:commentable => @news_item)
      #  @comment.profile = current_user.profile
      #end
      render :show
    end
  end
  def index
    @news = News.published.order{published_time.desc}.limit(10)
    if user_signed_in?
      profile = current_user.profile
      @notifications =  profile.mailbox.notifications.limit(10)
    end
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