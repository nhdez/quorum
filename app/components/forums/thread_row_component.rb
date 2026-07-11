module Forums
  class ThreadRowComponent < ApplicationComponent
    def initialize(thread:, path: "#")
      @thread = thread
      @path = path
    end

    attr_reader :thread, :path
  end
end
