class AdminMailer < ActionMailer::Base
  default from: "theSkyNet <#{APP_CONFIG['smtp_default_from']}>"
  def debug(msg,subject)
    @body = msg
    mail to: APP_CONFIG["admin_email"], subject: subject
  end
end
