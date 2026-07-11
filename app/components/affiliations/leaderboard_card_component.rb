module Affiliations
  class LeaderboardCardComponent < ApplicationComponent
    def initialize(label:, entry:)
      @label = label
      @entry = entry
    end

    attr_reader :label, :entry
  end
end
