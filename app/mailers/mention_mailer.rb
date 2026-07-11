class MentionMailer < ApplicationMailer
  def mention
    @recipient = params[:recipient]
    @post = params[:record]
    @thread = @post.is_a?(ForumThread) ? @post : @post.forum_thread
    @mentioner = @post.user

    mail to: @recipient.email, subject: "#{@mentioner.display_name} mentioned you on Quorum"
  end
end
