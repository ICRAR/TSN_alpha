class ContactFormsController < ApplicationController
  #authorize_resource
  def new
    @contact_form = ContactForm.new
    if user_signed_in?
      @contact_form.name = current_user.profile.name
      @contact_form.email = current_user.email
    end
  end

  def create
    begin
      if user_signed_in?
        params_merge = params[:contact_form].merge({
                                                       :profile_id => current_user.profile.id,
                                                       :email_db => current_user.email,
                                                       :name_db => current_user.profile.name

                                                   })
        @contact_form = ContactForm.new(params_merge)
      else
        @contact_form = ContactForm.new(params[:contact_form])
      end
      @contact_form.request = request
      if @contact_form.valid? && !@contact_form.spam?
        @contact_form.delay_send
        flash.now[:notice] = t "contact_forms.controller.thank_you"
      else
        render :new
      end
    rescue ScriptError
      flash[:error] = t "contact_forms.controller.spam"
    end
  end

end
