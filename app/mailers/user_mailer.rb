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
end
