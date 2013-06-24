class NereusController < ApplicationController
  authorize_resource :class => NereusStatsItem
  def run
    servers = APP_CONFIG['nereus_servers']
    @server = servers[rand(servers.length)]
    if user_signed_in?
      @nereus = current_user.profile.general_stats_item.nereus_stats_item
    else
      @nereus = nil
    end
    @nereus_id = @nereus == nil ? '-1' : @nereus.nereus_id
    render :run, :layout => false
  end
  def new
    #check if user is signed in
    if user_signed_in?
      @profile = current_user.profile
    else
      redirect_to root_url, notice: 'You must be logged in to do that.'
      return
    end

    #check if user already has a nereus account (you can only have one)
    if @profile.general_stats_item.nereus_stats_item != nil
      redirect_to root_url, notice: 'You can only have one nereus account.'
      return
    end

    #create account
    @profile.general_stats_item.nereus_stats_item = NereusStatsItem.new_account
    @profile.new_profile_step = [3,@profile.new_profile_step].max
    @profile.save
    @profile.general_stats_item.save

    #render :new page
    render :new
  end
end