require "test_helper"

module Users
  class StatsPanelComponentTest < ViewComponent::TestCase
    test "renders each stat row" do
      stats = [ { label: "Joined", value: "March 2019" }, { label: "Total Posts", value: "4,821" } ]

      render_inline(StatsPanelComponent.new(stats: stats))

      assert_text "Joined"
      assert_text "March 2019"
      assert_text "Total Posts"
      assert_text "4,821"
    end
  end
end
