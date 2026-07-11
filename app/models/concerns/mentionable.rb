module Mentionable
  extend ActiveSupport::Concern

  included do
    after_create_commit :notify_mentioned_users
  end

  private

  def notify_mentioned_users
    mentioned_users.each do |mentioned_user|
      next if mentioned_user == user

      MentionNotifier.with(record: self).deliver(mentioned_user)
    end
  end

  def mentioned_users
    body.body.attachables.select { |attachable| attachable.is_a?(User) }.uniq
  end
end
