class PagesController < ApplicationController
 authorize_resource
  def show
    user_admin = (user_signed_in? && current_user.admin?)
    slug = params[:slug]
    @page = Page.find_by_slug(params[:slug]) || not_found
    if @page.preview?
      not_found unless (user_signed_in? && current_user.admin?)
    end
    if (@page.parent)
      @title = @page.parent.title
      @links = @page.parent.sub_pages.for_links(user_admin)
      @content = @page.content.html_safe
    elsif (!@page.science_portal_id.nil?)
      @title = @page.science_portal.name
      @links = @page.science_portal.pages.for_links(user_admin)
      @content = @page.content.html_safe
    else
      @title = @page.title
      @links = @page.sub_pages.for_links(user_admin)
      @content = @page.content.html_safe
    end
    render :show

  end
  def index
    $statsd.increment 'index.view'
    @page =  Page.find_by_slug('index')
    if @page.nil?
      @page = Page.new()
      @page.content = "hello world"
    end
    @news = News.published.order{published_time.desc}.limit(5)
    @TFLOPSStat = SiteStat.get('global_TFLOPS')
    @feed = SiteStat.for_feed
    @top_profiles = Profile.for_leader_boards_small.order("rank asc").limit(10)
    @top_alliances = Alliance.for_leaderboard_small.order('ranking asc').limit(10)
    @activity = Activity.last(10)

    render :index
  end
end