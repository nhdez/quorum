module Forums
  class ThreadListComponent < ApplicationComponent
    def initialize(threads:, thread_path: ->(_thread) { "#" })
      @threads = threads
      @thread_path = thread_path
    end

    attr_reader :threads

    def path_for(thread)
      @thread_path.call(thread)
    end
  end
end
