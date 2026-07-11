class Announcement < ApplicationRecord
  validates :text, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(created_at: :desc) }
end
