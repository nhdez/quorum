class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  belongs_to :faction, optional: true

  AVATAR_COLORS = [ "#2455a4", "#7d97c2", "#1e8449", "#a85050", "#6b7aa8", "#8a8f9a", "#3f6fa0", "#9a8a3f" ].freeze

  def display_name
    email.split("@").first
  end

  def rank_label
    has_role?(:admin) ? "Administrator" : "Member"
  end

  def rank_color
    has_role?(:admin) ? "#c0392b" : "#1c2733"
  end

  def avatar_color
    AVATAR_COLORS[Zlib.crc32(id) % AVATAR_COLORS.length]
  end

  def post_count
    forum_threads.count + thread_replies.count
  end
end
