class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: %i[votable_type votable_id] }
end
