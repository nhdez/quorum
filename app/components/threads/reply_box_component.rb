module Threads
  class ReplyBoxComponent < ApplicationComponent
    def initialize(reply_path:)
      @reply_path = reply_path
    end

    attr_reader :reply_path
  end
end
