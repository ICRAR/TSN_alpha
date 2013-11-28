# app/mailers/mail_preview.rb or lib/mail_preview.rb
class MailPreview < MailView
  def alliance_sync_removal
    UserMailer.alliance_sync_removal(Profile.last,Alliance.first,Alliance.last)
  end
  def alliance_invite
    invite = invite = AllianceInvite.new(:email => "foo@bar.com")
    alliance = Alliance.first
    invite.alliance_id = alliance.id
    invite.invited_by_id =  alliance.members.first.id
    mail = UserMailer.alliance_invite invite
    invite.destroy
    mail
  end
  def alliance_merger_issue
    UserMailer.alliance_merger_issue(Profile.last, Alliance.last)
  end
  def devise_confirmation
    user = User.last
    Devise::Mailer.confirmation_instructions(user, token: "token")
  end
end