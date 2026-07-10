class Forum < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :forum_category
end
