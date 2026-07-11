module Forums
  class LatestPostsComponent < ApplicationComponent
    def initialize(posts:)
      @posts = posts
    end

    attr_reader :posts
  end
end
