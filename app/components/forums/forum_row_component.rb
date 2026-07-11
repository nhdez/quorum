module Forums
  class ForumRowComponent < ApplicationComponent
    def initialize(forum:)
      @forum = forum
    end

    attr_reader :forum
  end
end
