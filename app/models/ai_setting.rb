class AiSetting < ApplicationRecord
  AVAILABLE_MODELS = {
    "claude-opus-4-8" => "Claude Opus 4.8 (most capable)",
    "claude-sonnet-5" => "Claude Sonnet 5 (balanced)",
    "claude-haiku-4-5" => "Claude Haiku 4.5 (fastest/cheapest)"
  }.freeze

  encrypts :api_key

  validates :model_id, inclusion: { in: AVAILABLE_MODELS.keys }

  def self.instance
    first_or_create!
  end

  def configured?
    api_key.present?
  end
end
