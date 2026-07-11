module Ui
  class NavBarComponent < ApplicationComponent
    LINKS = [
      { key: :home, label: "Home", href: "/" },
      { key: :forums, label: "Forums", href: "/" },
      { key: :affiliations, label: "Affiliations", href: "/affiliations" },
      { key: :members, label: "Member List", href: "/members/political-junkie-88" },
      { key: :ai_flags, label: "AI Flags", href: "/ai-flags" },
      { key: :calendar, label: "Calendar", href: "#" },
      { key: :search, label: "Search", href: "#" },
      { key: :rules, label: "Rules", href: "#" }
    ].freeze

    def initialize(current: :forums)
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
