class ForumThread < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  include FallacyScannable
  include Votable
  include Mentionable

  belongs_to :forum
  belongs_to :user
  has_many :thread_replies, dependent: :destroy
  has_rich_text :body

  validates :title, presence: true
  validates :body, presence: true

  def fallacy_scan_forum
    forum
  end
end
