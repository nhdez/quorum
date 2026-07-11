class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  # Lets a User be @mentioned as a rich-text attachment (see Mentionable).
  include ActionText::Attachable
  include HasSignature

  validates :country_code, inclusion: { in: Country::LIST.keys }, allow_blank: true
  validates :public_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website_url, format: { with: %r{\Ahttps?://[^\s/$.?#].[^\s]*\z}i }, allow_blank: true
  validate :date_of_birth_is_plausible

  belongs_to :faction, optional: true
  has_many :forum_threads, dependent: :destroy
  has_many :thread_replies, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"

  AVATAR_COLORS = [ "#2455a4", "#7d97c2", "#1e8449", "#a85050", "#6b7aa8", "#8a8f9a", "#3f6fa0", "#9a8a3f" ].freeze

  def display_name
    email.split("@").first
  end

  def full_name
    [ first_name, last_name ].compact_blank.join(" ").presence
  end

  def country_name
    Country.name_for(country_code)
  end

  def flag_emoji
    Country.flag_for(country_code)
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

  def received_votes_count
    Vote.where(votable_type: "ForumThread", votable_id: forum_thread_ids).count +
      Vote.where(votable_type: "ThreadReply", votable_id: thread_reply_ids).count
  end

  def recommended_post_count
    forum_threads.where(recommended: true).count + thread_replies.where(recommended: true).count
  end

  # Dispatches a RankCondition's metric key to the matching stat. Add a
  # branch here when a new metric is introduced in RankCondition::METRICS.
  def stat_for(metric)
    case metric
    when "post_count" then post_count
    when "vote_count" then received_votes_count
    when "recommended_count" then recommended_post_count
    else 0
    end
  end

  # The highest-tier Rank whose conditions this user currently satisfies,
  # or nil if none are met yet. Computed on the fly (no stored column) —
  # consistent with how rank_label/post_count already work, and avoids
  # any staleness between a user's activity and their displayed rank.
  def current_rank
    Rank.ordered.reverse_each.find { |rank| rank.earned_by?(self) }
  end

  private

  def date_of_birth_is_plausible
    return if date_of_birth.blank?

    errors.add(:date_of_birth, "can't be in the future") if date_of_birth.future?
    errors.add(:date_of_birth, "is not valid") if date_of_birth < 150.years.ago.to_date
  end
end
