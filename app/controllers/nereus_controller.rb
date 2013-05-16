class NereusController < ApplicationController
  authorize_resource :class => false
  def run
    servers = APP_CONFIG['nereus_servers']
    @server = servers[rand(servers.length)]
    @nereus = NereusStatsItem.where(:nereus_id => params[:id]).first
    @nereus_id = @nereus == nil ? '' : @nereus.nereus_id
    render :show, :layout => false
  end
end