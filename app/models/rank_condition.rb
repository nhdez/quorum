class RankCondition < ApplicationRecord
  METRICS = {
    "post_count" => "Post count",
    "vote_count" => "Votes received",
    "recommended_count" => "Highlighted posts"
  }.freeze

  belongs_to :rank

  validates :metric, inclusion: { in: METRICS.keys }
  validates :threshold, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def met_by?(user)
    user.stat_for(metric) >= threshold
  end

  def label
    METRICS.fetch(metric, metric)
  end
end
