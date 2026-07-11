module Admin
  class DashboardController < BaseController
    def index
      @admin_nav_current = :dashboard

      posts_today = ForumThread.where(created_at: Date.current.all_day).count +
                    ThreadReply.where(created_at: Date.current.all_day).count
      pending_count = User.where(confirmed_at: nil).count

      @stat_cards = [
        { label: "Total Members", value: User.count.to_s, color: nil },
        { label: "Posts Today", value: posts_today.to_s, color: nil },
        { label: "Pending Registrations", value: pending_count.to_s, color: "#a0824f" },
        { label: "Reports Awaiting Review", value: "2", color: "#a0524f" },
        { label: "AI Flags Today", value: "17", color: "#6b4fa0" }
      ]

      @sensitivity = 55
      @bot_toggles = [
        { label: "Ad hominem attacks", on: true },
        { label: "Loaded / inflammatory language", on: true },
        { label: "Source dismissal without rebuttal", on: false }
      ]

      @pending_registrations = User.where(confirmed_at: nil).order(created_at: :desc)

      @reports = [
        { thread: "Anyone else think the debate moderators were biased?", excerpt: "only someone completely out of touch would think that moderation was fair.", reporter: "quietobserver", reason: "Personal attack" },
        { thread: "International Affairs mega-thread: Ukraine talks", excerpt: "anyone still defending that policy hasn't been paying attention at all.", reporter: "moderate_marie", reason: "Inflammatory language" }
      ]
    end
  end
end
