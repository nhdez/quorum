class FallacyDetectionJob < ApplicationJob
  queue_as :default

  def perform(post)
    FallacyDetection::Scanner.new(post).call
  end
end
