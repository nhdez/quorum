module FallacyScannable
  extend ActiveSupport::Concern

  included do
    has_many :fallacy_flags, as: :flaggable, dependent: :destroy

    after_commit :enqueue_fallacy_scan, on: %i[create update]
  end

  # The Forum this post lives under, used to resolve which fallacy
  # definitions are active. Must be implemented by the including model.
  def fallacy_scan_forum
    raise NotImplementedError
  end

  private

  def enqueue_fallacy_scan
    FallacyDetectionJob.set(wait: 10.seconds).perform_later(self)
  end
end
