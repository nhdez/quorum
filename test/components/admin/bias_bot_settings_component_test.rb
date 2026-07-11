require "test_helper"

module Admin
  class BiasBotSettingsComponentTest < ViewComponent::TestCase
    test "renders the sensitivity and each toggle" do
      toggles = [ { label: "Ad hominem attacks", on: true }, { label: "Source dismissal", on: false } ]

      render_inline(BiasBotSettingsComponent.new(sensitivity: 55, toggles: toggles))

      assert_text "55%"
      assert_text "Ad hominem attacks"
      assert_text "Source dismissal"
    end
  end
end
