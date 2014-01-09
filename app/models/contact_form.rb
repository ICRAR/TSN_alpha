class ContactForm < MailForm::Base
  attributes :name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :profile_id
  attributes :email_db
  attributes :name_db
  attributes :message
  attributes :nickname,   :captcha => true

  def headers
    {
        :subject => "Contact Support Ticket from theSkyNet",
        :to => "help.theskynet@gmail.com",
        :from => %("#{name}" <#{email}>)
    }
  end


  #allows delayed sending of emails
  def delay_send
    ContactForm.delay.delay_send(self.mail_form_attributes)
  end
  def self.delay_send(params)
    #send email to person
    UserMailer.contact_support(params["name"],params["email"],params["message"]).deliver

    #send email to help desk
    contact = ContactForm.new(params)
    contact.deliver
  end
end