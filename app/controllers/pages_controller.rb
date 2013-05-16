class PagesController < ApplicationController
 load_and_authorize_resource
  def show
    @page = Page.find_by_slug(params[:slug])
    if (@page.parent)
      @title = @page.parent.title
      @links = @page.parent.sub_pages.all
      @content = @page.content.html_safe
    else
      @title = @page.title
      @links = @page.sub_pages.all
      @content = @page.content.html_safe
    end
    render :show
  end
  def index


    $statsd.increment 'index.view'
    @page =  Page.find_by_slug('index')
    @news = News.published.all
    render :index
  end
end