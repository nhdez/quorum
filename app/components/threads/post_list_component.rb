module Threads
  class PostListComponent < ApplicationComponent
    def initialize(posts:)
      @posts = posts
    end

    attr_reader :posts
  end
end
