module Affiliations
  class FactionCardComponent < ApplicationComponent
    def initialize(faction:, current_user:)
      @faction = faction
      @current_user = current_user
    end

    attr_reader :faction, :current_user

    def joined?
      current_user.present? && current_user.faction_id == faction.id
    end

    def member_count
      faction.users.count
    end
  end
end
