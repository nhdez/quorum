module Threads
  class ReplyBoxComponent < ApplicationComponent
    def initialize(reply_path:, max_word_count: nil)
      @reply_path = reply_path
      @max_word_count = max_word_count
    end

    attr_reader :reply_path, :max_word_count
  end
end
