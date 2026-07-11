module Admin
  class StatCardComponent < ApplicationComponent
    def initialize(label:, value:, color: nil)
      @label = label
      @value = value
      @color = color
    end

    attr_reader :label, :value, :color
  end
end
