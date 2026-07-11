module Admin
  class SidebarComponent < ApplicationComponent
    LINKS = [
      { key: :dashboard, label: "Dashboard", path: :admin_dashboard_path },
      { key: :members, label: "Members" },
      { key: :boards, label: "Forums & Boards", path: :admin_boards_path },
      { key: :reports, label: "Reported Posts" },
      { key: :bias_bot, label: "AI Bias Bot" },
      { key: :fallacy_detection, label: "Fallacy Detection", path: :admin_fallacy_definitions_path },
      { key: :affiliations, label: "Affiliations" },
      { key: :announcements, label: "Announcements" },
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
