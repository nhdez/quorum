module AiFlags
  class FlagLogComponent < ApplicationComponent
    def initialize(flags:)
      @flags = flags
    end

    attr_reader :flags
  end
end
