module Ui
  class PanelComponent < ApplicationComponent
    def initialize(title: nil, note: nil, accent_color: nil)
      @title = title
      @note = note
      @accent_color = accent_color
    end

    attr_reader :title, :note, :accent_color
  end
end
