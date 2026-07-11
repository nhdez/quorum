module Users
  class StatsPanelComponent < ApplicationComponent
    def initialize(stats:)
      @stats = stats
    end

    attr_reader :stats
  end
end
