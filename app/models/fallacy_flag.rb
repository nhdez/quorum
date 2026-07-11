class FallacyFlag < ApplicationRecord
  belongs_to :flaggable, polymorphic: true
  belongs_to :fallacy_definition

  validates :excerpt, presence: true
  validates :confidence, numericality: { in: 0.0..1.0 }

  scope :visible, -> { where(dismissed_by_author: false) }
end
