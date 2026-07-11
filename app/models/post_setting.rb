class PostSetting < ApplicationRecord
  validates :max_word_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def self.instance
    first_or_create!
  end
end
