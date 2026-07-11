module Threads
  class VoteBarComponent < ApplicationComponent
    def initialize(choices:, total:)
      @choices = choices
      @total = total
    end

    attr_reader :choices, :total
  end
end
