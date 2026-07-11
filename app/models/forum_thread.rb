class ForumThread < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :forum
  belongs_to :user
  has_many :thread_replies, dependent: :destroy
  has_rich_text :body

  validates :title, presence: true
  validates :body, presence: true
end
