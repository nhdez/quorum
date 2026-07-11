require "test_helper"

module Affiliations
  class LeaderboardCardComponentTest < ViewComponent::TestCase
    test "renders the label and entry" do
      render_inline(LeaderboardCardComponent.new(
        label: "This Week — Most Active",
        entry: { name: "Progressive Alliance", color: "#6b4fa0", stat: "1,204 posts this week" }
      ))

      assert_text "This Week — Most Active"
      assert_text "Progressive Alliance"
      assert_text "1,204 posts this week"
    end
  end
end
