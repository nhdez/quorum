module Ui
  class PaginationComponent < ApplicationComponent
    def initialize(pages:)
      @pages = pages
    end

    attr_reader :pages
  end
end
