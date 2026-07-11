module Forums
  class CategoryPanelComponent < ApplicationComponent
    def initialize(name:, forums:)
      @name = name
      @forums = forums
    end

    attr_reader :name, :forums
  end
end
