module Admin
  class ReportsComponent < ApplicationComponent
    def initialize(reports:)
      @reports = reports
    end

    attr_reader :reports
  end
end
