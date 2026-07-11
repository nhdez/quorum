module Admin
  class SidebarComponent < ApplicationComponent
    LINKS = [
      { key: :dashboard, label: "Dashboard", path: :admin_dashboard_path },
      { key: :members, label: "Members", path: :admin_members_path },
      { key: :user_groups, label: "User Groups", path: :admin_user_groups_path },
      { key: :ranks, label: "Ranks", path: :admin_ranks_path },
      { key: :boards, label: "Forums & Boards", path: :admin_boards_path },
      { key: :reports, label: "Reported Posts" },
      { key: :bias_bot, label: "AI Bias Bot" },
      { key: :fallacy_detection, label: "Fallacy Detection", path: :admin_fallacy_definitions_path },
      { key: :affiliations, label: "Affiliations" },
      { key: :announcements, label: "Announcements", path: :admin_announcements_path },
      { key: :smtp_settings, label: "Email (SMTP)", path: :edit_admin_smtp_settings_path },
      { key: :storage_settings, label: "Object Storage", path: :edit_admin_storage_settings_path },
      { key: :post_settings, label: "Post Settings", path: :edit_admin_post_settings_path },
      { key: :settings, label: "Settings", path: :edit_admin_ai_settings_path }
    ].freeze

    def initialize(current: :dashboard)
      @current = current
    end

    def links
      LINKS
    end

    def active?(link)
      link[:key] == @current
    end
  end
end
