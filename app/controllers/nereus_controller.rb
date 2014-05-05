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
    return
    #check if user is signed in
    if user_signed_in?
      @profile = current_user.profile
    else
      redirect_to root_url, alert: 'You must be logged in to do that.'
      return
    end

    #check if user already has a nereus account (you can only have one)
    if @profile.general_stats_item.nereus_stats_item != nil
      redirect_to my_profile_url, alert: 'You can only have one nereus account.'
      return
    end
    if params[:nereus_id].nil?
      #create account
      @profile.general_stats_item.nereus_stats_item = NereusStatsItem.new_account
      @profile.new_profile_step = [3,@profile.new_profile_step].max
      @profile.save
      @profile.general_stats_item.save

      #render :new page
      render :new
    else
      #link account
      nereus_item = NereusStatsItem.find_by_nereus_id(params[:nereus_id])
      if nereus_item.nil?
        redirect_to my_profile_url, alert: 'Sorry we could not find that nereus account.'
        return
      end
      if !nereus_item.general_stats_item_id.nil?
        redirect_to my_profile_url, alert: 'Sorry that nereus has already been linked. If you believe this is an error please contact a site admin.'
        return
      end
      @profile.general_stats_item.nereus_stats_item = nereus_item
      nereus_item.save
      redirect_to my_profile_url notice: "Succsess your account has been linked"
    end

  end
  def send_cert
    #check if user is signed in
    if user_signed_in?
      @profile = current_user.profile
      nereus = @profile.general_stats_item.nereus_stats_item
      #check that user has a nereus account
      if nereus.nil?
        return_data = {:success => false, :message => 'You must have a nereus account to do this.'}
      #check that the user is a founding member
      elsif  !nereus.founding?
        return_data = {:success => false, :message => 'You are not a founding member.'}
      #try to send the sert
      elsif nereus.send_cert
        return_data = {:success => true, :message => "Success a certificate is on it's way to you"}
      else
        return_data = {:success => false, :message => 'A certificate is already on its way. If you do not receive it soon please try again.'}
      end
    else
      return_data = {:success => false, :message => 'You must be logged in to do that.'}
    end

    render json: return_data
  end
end