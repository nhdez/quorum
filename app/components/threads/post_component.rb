module Threads
  class PostComponent < ApplicationComponent
    def initialize(post:)
      @post = post
    end

    attr_reader :post
  end
end
