module Ui
  class MastheadComponent < ApplicationComponent
    def initialize(current_user: nil)
      @current_user = current_user
    end

    attr_reader :current_user

    def signed_in?
      current_user.present?
    end

    def display_name
      current_user.email.split("@").first
    end
  end
end
