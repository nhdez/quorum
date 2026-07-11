module Users
  class AboutMeComponent < ApplicationComponent
    def initialize(bio:, signature: nil)
      @bio = bio
      @signature = signature
    end

    attr_reader :bio, :signature
  end
end
