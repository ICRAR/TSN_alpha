class CommentsController < ApplicationController
  include ERB::Util
  authorize_resource
  def index
    @comments = Comment.for_show_index.page(params[:page]).per(20)
  end
  def new
    @comment = Comment.new(:parent_id => params[:parent_id],
                           :commentable_id => params[:commentable_id],
                           :commentable_type => params[:commentable_type]
                          )
    @comment.profile = current_user.profile
    respond_to do |format|
      format.html
      format.js
    end
  end
  def create
    @comment = Comment.new(params[:comment])
    @comment.profile = current_user.profile
    @comment.save
    Comment.notify_users(@commnet.id) unless @comment.errors.present?
    respond_to do |format|
      format.html do
        if @comment.errors.present?
          render :new
        else
          redirect_to(@comment.commentable)
        end
      end
      format.js
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    authorize! :update, @comment
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    authorize! :destroy, @comment
    @comment.destroy
    flash[:notice] = "Deleted comment."
    respond_to do |format|
      format.html { redirect_to @comment.commentable }
      format.js
    end
  end

  def update
    @comment = Comment.find(params[:id])
    authorize! :update, @comment
    @comment.update_attributes(params[:comment])
    respond_to do |format|
      format.html do
        if @comment.errors.present?
          render :edit
        else
          redirect_to @comment.commentable
        end
      end
      format.js
    end
  end

  def report
    ## sends an email to support desk stating.
    ## only works for signed_in users
    @comment = Comment.find(params[:id])
    authorize! :report, @comment
    if user_signed_in?
      @contact_form = ContactForm.new
      @contact_form.name = current_user.profile.name
      @contact_form.email = current_user.email
      @contact_form.profile_id = current_user.profile.id
      @contact_form.email_db = current_user.email
      @contact_form.name_db = current_user.profile.name

      @contact_form.message = "Comment (#{@comment.id}) on <a href=\"#{polymorphic_url(@comment.commentable)}\">#{@comment.commentable_name}</a> has been reported."
      @contact_form.message << "<br />"
      @contact_form.message << "Reason: <br />".html_safe
      @contact_form.message << ERB::Util.html_escape(params[:reason])
      @contact_form.message << "<br />"
      @contact_form.message << "Comment: <br />".html_safe
      @contact_form.message << ERB::Util.html_escape(@comment.content)

      @contact_form.request = request
      if @contact_form.valid?
        @contact_form.delay_send
        flash[:notice] = "Thank you for reporting."
      else
        flash[:notice] = "Something went wrong"
      end
      redirect_to @comment.commentable
    else
      redirect_to root_url, :notice => "You must be logged in to do that"
    end
  end
end