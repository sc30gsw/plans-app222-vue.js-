class CommentsController < ApplicationController

  def create
    @comment = Comment.new(comment_params)
    if @comment.valid?
      @comment.save
      redirect_to note_path(@comment.note)
    else
      @note = @comment.note
      @comments = @note.comments
      render "notes/show"
    end
  end

  private

  def comment_params
    params.require(:cooment).permit(:text, :image).merge(user_id: current_user.id, note_id: params[:note_id])
  end
end