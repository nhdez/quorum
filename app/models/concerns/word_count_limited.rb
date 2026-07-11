module WordCountLimited
  extend ActiveSupport::Concern

  included do
    validate :body_within_word_limit
  end

  private

  def body_within_word_limit
    max = PostSetting.instance.max_word_count
    return if max.blank? || body.blank?

    count = body.to_plain_text.split(/\s+/).reject(&:blank?).size
    errors.add(:body, "is too long (#{count} words; #{max} max)") if count > max
  end
end
