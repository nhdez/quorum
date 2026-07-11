class ThreadReply < ApplicationRecord
  include FallacyScannable
  include Votable

  belongs_to :forum_thread
  belongs_to :user
  has_rich_text :body

  validates :body, presence: true

  def fallacy_scan_forum
    forum_thread.forum
  end
end
