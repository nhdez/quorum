module Admin
  class PendingRegistrationsComponent < ApplicationComponent
    def initialize(users:)
      @users = users
    end

    attr_reader :users
  end
end
