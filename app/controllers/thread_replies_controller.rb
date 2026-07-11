class ThreadRepliesController < ApplicationController
  before_action :authenticate_user!

  def create
    forum = Forum.friendly.find(params[:forum_id])
    thread = forum.forum_threads.friendly.find(params[:thread_id])
    reply = thread.thread_replies.build(reply_params)
    reply.user = current_user

    if reply.save
      redirect_to forum_thread_path(forum, thread), notice: "Reply posted."
    else
      redirect_to forum_thread_path(forum, thread), alert: reply.errors.full_messages.to_sentence
    end
  end

  private

  def reply_params
    params.require(:thread_reply).permit(:body)
  end
end
