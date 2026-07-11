class FallacyDefinition < ApplicationRecord
  SEVERITIES = { low: 0, medium: 1, high: 2 }.freeze

  has_many :fallacy_scope_settings, dependent: :destroy
  has_many :fallacy_flags, dependent: :destroy

  enum :default_severity, SEVERITIES

  validates :key, presence: true, uniqueness: true
  validates :display_name, :short_description, :long_description, :detection_prompt_fragment, presence: true
  validates :default_confidence_threshold, numericality: { in: 0.0..1.0 }

  def enabled_for?(scope)
    setting = fallacy_scope_settings.find_by(scope: scope)
    return default_enabled if setting.nil? || setting.enabled.nil?

    setting.enabled
  end

  def confidence_threshold_for(scope)
    setting = fallacy_scope_settings.find_by(scope: scope)
    return default_confidence_threshold if setting.nil? || setting.confidence_threshold.nil?

    setting.confidence_threshold
  end
end
