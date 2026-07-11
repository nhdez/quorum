require "test_helper"

module Ui
  class PanelComponentTest < ViewComponent::TestCase
    test "renders the title, note, and yielded content" do
      render_inline(PanelComponent.new(title: "Statistics", note: "Updated daily")) { "Panel body" }

      assert_text "Statistics"
      assert_text "Updated daily"
      assert_text "Panel body"
    end

    test "omits the header entirely when no title is given" do
      render_inline(PanelComponent.new) { "Just content" }

      assert_text "Just content"
    end
  end
end
