require "test_helper"

module Forums
  class StatsPanelComponentTest < ViewComponent::TestCase
    test "renders the stats and newest member" do
      render_inline(StatsPanelComponent.new(threads: "100", posts: "200", members: "300", newest_member: "skeptical_sam"))

      assert_text "100"
      assert_text "200"
      assert_text "300"
      assert_text "skeptical_sam"
    end
  end
end
