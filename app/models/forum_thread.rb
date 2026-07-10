class ForumThread < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :forum
end
