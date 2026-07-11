module Admin
  class SidebarComponent < ApplicationComponent
    LINKS = [
      { key: :dashboard, label: "Dashboard", path: :admin_dashboard_path },
      { key: :members, label: "Members" },
      { key: :boards, label: "Forums & Boards" },
      { key: :reports, label: "Reported Posts" },
      { key: :bias_bot, label: "AI Bias Bot" },
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
