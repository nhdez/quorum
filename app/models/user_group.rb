class UserGroup < ApplicationRecord
  SYSTEM_GROUP_NAMES = %w[Administrator Moderator Registered].freeze
  SYSTEM_GROUP_COLORS = { "Administrator" => "#c0392b", "Moderator" => "#1e8449", "Registered" => "#1c2733" }.freeze

  has_one_attached :banner

  validates :name, presence: true, uniqueness: true
  validates :badge_color, presence: true
  validate :name_cannot_change_on_system_group, on: :update

  before_destroy :prevent_destroying_system_group

  scope :ordered, -> { order(system_group: :desc, index_order: :asc, name: :asc) }

  # Guarantees the three non-negotiable default groups exist. Safe to
  # call repeatedly (e.g. on every admin page load) since it's a no-op
  # once they're already present.
  def self.ensure_system_groups!
    SYSTEM_GROUP_NAMES.each do |group_name|
      find_or_create_by!(name: group_name) do |group|
        group.system_group = true
        group.badge_color = SYSTEM_GROUP_COLORS.fetch(group_name)
      end
    end
  end

  private

  def name_cannot_change_on_system_group
    errors.add(:name, "can't be changed for a default group") if system_group? && name_changed?
  end

  def prevent_destroying_system_group
    return unless system_group?

    errors.add(:base, "Default groups can't be removed")
    throw :abort
  end
end
