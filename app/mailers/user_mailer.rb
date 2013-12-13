class UserMailer < ActionMailer::Base
  default from: APP_CONFIG['smtp_default_from']
  def alliance_invite(invite)
    @name = invite.invited_by.name
    @alliance_name = invite.alliance.name
    @alliance_id = invite.alliance.id
    @email = invite.email
    @token = invite.token
    mail to: invite.email, subject: "#{@name} has invited you to join theSkyNet"
  end
  def alliance_sync_removal(profile, old_alliance, new_alliance)
    @profile =  profile
    @old_alliance = old_alliance
    @new_alliance = new_alliance
    email = profile.user.email
    mail to: email, subject: "You're theSkyNet Alliance has changed"
  end
  def alliance_merger_issue(profile,alliance)
    @profile = profile
    @alliance = alliance

    email = profile.user.email
    mail to: email, subject: "You're theSkyNet Alliance has changed"
  end
  def welcome_msg(user_id)
    user = User.find user_id
    @profile = user.profile
    email = user.email
    mail to: email, subject: 'Welcome to theSkyNet'

  end
  def advent_notify(user)
    start_day = Time.parse('13th, December 2013')
    now = Time.now
    @day = ((now - start_day)/1.day).ceil
    @profile = user.profile
    email = user.email
    mail to: email, subject: 'Next Christmas Box Unlocked'
  end
end
