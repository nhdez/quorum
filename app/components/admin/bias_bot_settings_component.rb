module Admin
  class BiasBotSettingsComponent < ApplicationComponent
    def initialize(sensitivity:, toggles:)
      @sensitivity = sensitivity
      @toggles = toggles
    end

    attr_reader :sensitivity, :toggles
  end
end
