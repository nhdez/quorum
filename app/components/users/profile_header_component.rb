module Users
  class ProfileHeaderComponent < ApplicationComponent
    def initialize(profile:)
      @profile = profile
    end

    attr_reader :profile
  end
end
