class CommentsController < ApplicationController
  authorize_resource
  def new
    @comment = Comment.new(:parent_id => params[:parent_id],
                           :commentable_id => params[:commentable_id],
                           :commentable_type => params[:commentable_type]
                          )
    @comment.profile = current_user.profile
  end
  def create
    @comment = Comment.new(params[:comment])
    @comment.profile = current_user.profile
    @comment.save
    respond_to do |format|
      format.html do
        if @comment.errors.present?
          render :new
        else
          redirect_to(episode_path(@comment.episode, :view => "comments"))
        end
      end
      format.js
    end
  end
end