class NotificationsController < ApplicationController
  before_filter :notify_auth
  skip_before_filter :check_announcement
  skip_before_filter :special_days
  def notify_auth
    if user_signed_in?
      if current_user.admin? && !params[:profile_id].nil?
        @profile = Profile.find(params[:profile_id])
      else
        @profile = current_user.profile
      end
      if @profile.nil?
        redirect_to profiles_url, notice: 'Sorry could not find your profile'
        return
      end
    else
      redirect_to root_url, notice: 'You must be logged in to view your own profile.'
      return
    end
  end
  def index

    @notifications =  @profile.profile_notifications.limit(10).unread

  end
  def show
    @notification =  @profile.profile_notifications.find params[:id]
  end
  def dismiss_all
    @notifications =  @profile.profile_notifications.unread
    @notifications.each do |note|
      note.mark_as_read
    end

    render :index
  end
  def dismiss
    @notification =  @profile.profile_notifications.find params[:id]
    @notification.mark_as_read
    render :show
  end
end
