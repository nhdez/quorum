module Forums
  class ForumHeaderComponent < ApplicationComponent
    def initialize(title:, description:, subforums: [])
      @title = title
      @description = description
      @subforums = subforums
    end

    attr_reader :title, :description, :subforums
  end
end
