class MiscController < ApplicationController
  def advent
    params[:snow] == 'true'
    if params["day"] && user_signed_in? && current_user.is_admin?
      @current_day = params["day"].to_i
    else
      start_day = Time.parse('14th, December 2013')
      now = Time.now
      @current_day = ((now - start_day)/1.day).to_i
    end

    if params["last"] && user_signed_in? && current_user.is_admin?
      @last_day = params["last"].to_i
    elsif user_signed_in?
      @last_day = current_user.profile.advent_last_day
      @last_day ||= 0
      @last_day = [@last_day,@current_day].min
    else
      @last_day = 0
    end

    if params["update_last_day"]
      if user_signed_in?
        new_day = params["update_last_day"].to_i
        if new_day >= 0 && new_day <= @current_day
          current_user.profile.advent_last_day = new_day
          current_user.profile.save
          @last_day = new_day
        end
      else
        redirect_to new_user_session_path
        return
      end
    end

    render :advent, layout: false
  end

  def advent_subscribe
    if user_signed_in?
      if params[:add] == 'true'
        current_user.profile.advent_notify = true
        current_user.profile.save
        redirect_to advent_misc_path, notice: "Success you are now subscribed to receive notices for theSkyNet Christmas countdown."
      else
        current_user.profile.advent_notify = false
        current_user.profile.save
        redirect_to advent_misc_path, notice: "Success you are now unsubscribed from receiving notices for theSkyNet Christmas countdown."
      end
    else
      redirect_to root_url, notice: "Sorry you need to be logged in to do that."
    end
  end
end