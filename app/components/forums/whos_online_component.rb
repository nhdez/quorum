module Forums
  class WhosOnlineComponent < ApplicationComponent
    GROUP_LEGEND = [
      { label: "Administrator", color: "#c0392b" },
      { label: "Moderator", color: "#1e8449" },
      { label: "Senior Member", color: "#2455a4" },
      { label: "Member", color: "#333333" }
    ].freeze

    def initialize(users:, summary:)
      @users = users
      @summary = summary
    end

    attr_reader :users, :summary

    def legend
      GROUP_LEGEND
    end
  end
end
