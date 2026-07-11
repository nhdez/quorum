require "test_helper"

module Ui
  class PaginationComponentTest < ViewComponent::TestCase
    test "renders links, the current page, and ellipsis as plain text" do
      pages = [
        { label: "1", href: "#", current: true },
        { label: "2", href: "#" },
        { label: "…" }
      ]

      render_inline(PaginationComponent.new(pages: pages))

      assert_selector "span", text: "1"
      assert_selector "a", text: "2"
      assert_selector "span", text: "…"
    end
  end
end
