require "test_helper"

module Ui
  class NavBarComponentTest < ViewComponent::TestCase
    test "renders all nav links" do
      render_inline(NavBarComponent.new)

      Ui::NavBarComponent::LINKS.each do |link|
        assert_selector "a", text: link[:label]
      end
    end

    test "marks the current link active" do
      render_inline(NavBarComponent.new(current: :affiliations))

      active_link = page.find("a", text: "Affiliations")
      inactive_link = page.find("a", text: "Forums")

      assert_includes active_link[:class], "text-white"
      assert_not_includes inactive_link[:class], "text-white"
    end
  end
end
