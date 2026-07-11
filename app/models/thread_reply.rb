class ThreadReply < ApplicationRecord
  belongs_to :forum_thread
  belongs_to :user
  has_rich_text :body

  validates :body, presence: true
end
