class ContactForm < MailForm::Base
  attributes :name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :profile_id
  attributes :email_db
  attributes :name_db
  attributes :message, :validate => true
  attributes :nickname,   :captcha => true

  def headers
    {
        :subject => "Contact Support Ticket from theSkyNet",
        :to => "icrar.tsn.website@gmail.com",
        :from => "theSkyNet <admin@theSkyNet.org>" # %("#{name}" <#{email}>)
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
    contact.email = 'icrar.tsn.website@gmail.com'
    contact.name = 'theSkyNet'
    contact.message = "#{params["email"]}: #{contact.message.html_safe}" #contact.message = contact.message.html_safe
    contact.deliver
  end
end
