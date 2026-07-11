class Forum < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :forum_category
  belongs_to :parent_forum, class_name: "Forum", optional: true
  has_many :subforums, class_name: "Forum", foreign_key: :parent_forum_id, dependent: :destroy, inverse_of: :parent_forum
  has_many :forum_threads, dependent: :destroy

  validates :title, presence: true
  validate :parent_forum_cannot_itself_be_a_subforum

  scope :top_level, -> { where(parent_forum_id: nil) }
  scope :ordered, -> { order(:index_order) }

  private

  def parent_forum_cannot_itself_be_a_subforum
    return if parent_forum.blank?

    errors.add(:parent_forum, "can't be a subforum itself") if parent_forum.parent_forum_id.present?
  end
end
