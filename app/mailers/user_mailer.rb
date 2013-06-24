class UserMailer < ActionMailer::Base
  default from: "theskynet-dev@gmail.com"
  def alliance_invite(invite)
    @name = invite.invited_by.name
    @alliance_name = invite.alliance.name
    @alliance_id = invite.alliance.id
    @email = invite.email
    @token = invite.token
    mail to: invite.email, subject: "#{@name} has invited you to join the skynet"
  end
end
