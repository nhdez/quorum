class Rank < ApplicationRecord
  has_many :rank_conditions, dependent: :destroy

  validates :name, presence: true
  validates :tier, presence: true, uniqueness: true, numericality: { only_integer: true }
  validates :badge_color, presence: true

  scope :ordered, -> { order(tier: :asc) }

  # Returns true only if every one of this rank's conditions is met by user.
  # A rank with no conditions yet configured is never earned automatically
  # (avoids an in-progress/empty rank silently becoming everyone's rank).
  def earned_by?(user)
    return false if rank_conditions.empty?

    rank_conditions.all? { |condition| condition.met_by?(user) }
  end
end
