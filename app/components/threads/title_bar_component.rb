module Threads
  class TitleBarComponent < ApplicationComponent
    def initialize(title:)
      @title = title
    end

    attr_reader :title
  end
end
