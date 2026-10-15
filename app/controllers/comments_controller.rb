class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incident

  def create
    @comment = @incident.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to incident_path(@incident, anchor: "comments"), notice: "Comment added."
    else
      redirect_to incident_path(@incident, anchor: "comments"), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    comment = @incident.comments.find(params[:id])
    unless comment.user == current_user || current_user.admin?
      return redirect_to incident_path(@incident), alert: "You cannot remove this comment."
    end

    comment.destroy!
    redirect_to incident_path(@incident, anchor: "comments"), notice: "Comment removed.", status: :see_other
  end

  private

  def set_incident
    @incident = Incident.find(params[:incident_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
