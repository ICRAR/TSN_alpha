class PagesController < ApplicationController
 load_and_authorize_resource
  def show
    @page = Page.find_by_slug(params[:slug])
    render :inline => @page.content.html_safe, :layout => true
  end
  def index


    $statsd.increment 'index.view'
    @page =  Page.find_by_slug('index')
    @news = News.all_published
    render :index
  end
end