module Ui
  class BreadcrumbComponent < ApplicationComponent
    def initialize(items:)
      @items = items
    end

    attr_reader :items
  end
end
