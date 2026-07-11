class MentionNotifier < Noticed::Event
  deliver_by :email do |config|
    config.mailer = "MentionMailer"
    config.method = :mention
    # Always proceed outside production's DB-driven SMTP delivery method
    # (dev/test have their own working delivery methods regardless of
    # SmtpSetting); in production, skip cleanly instead of letting
    # DbSmtpDeliveryMethod raise when no admin has configured SMTP yet.
    config.if = -> { ActionMailer::Base.delivery_method != :db_smtp || SmtpSetting.instance.configured? }
  end

  notification_methods do
    def post
      record
    end

    def thread
      post.is_a?(ForumThread) ? post : post.forum_thread
    end

    def mentioner
      post.user
    end

    def message
      "#{mentioner.display_name} mentioned you in \"#{thread.title}\""
    end

    def url
      forum_thread_path(thread.forum, thread)
    end
  end
end
