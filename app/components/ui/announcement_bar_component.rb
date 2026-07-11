module Ui
  class AnnouncementBarComponent < ApplicationComponent
    def initialize(text:)
      @text = text
    end

    attr_reader :text
  end
end
