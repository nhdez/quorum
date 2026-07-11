class ForumCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :forums, dependent: :destroy

  validates :title, presence: true

  scope :ordered, -> { order(:index_order) }
end
