module Admin
  class TopBarComponent < ApplicationComponent
    def initialize(current_user:)
      @current_user = current_user
    end

    attr_reader :current_user
  end
end
