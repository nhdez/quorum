module Forums
  class StatsPanelComponent < ApplicationComponent
    def initialize(threads:, posts:, members:, newest_member:)
      @threads = threads
      @posts = posts
      @members = members
      @newest_member = newest_member
    end

    attr_reader :threads, :posts, :members, :newest_member
  end
end
