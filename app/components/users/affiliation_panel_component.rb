module Users
  class AffiliationPanelComponent < ApplicationComponent
    def initialize(affiliation:)
      @affiliation = affiliation
    end

    attr_reader :affiliation
  end
end
