class FallacyScopeSetting < ApplicationRecord
  belongs_to :fallacy_definition
  belongs_to :scope, polymorphic: true

  validates :confidence_threshold, numericality: { in: 0.0..1.0 }, allow_nil: true
end
