require "test_helper"

module Ui
  class BreadcrumbComponentTest < ViewComponent::TestCase
    test "renders each item and links non-current ones with an href" do
      items = [
        { label: "Quorum", href: "/" },
        { label: "General Discussion" },
        { label: "Politics & Current Events", current: true }
      ]

      render_inline(BreadcrumbComponent.new(items: items))

      assert_selector "a[href='/']", text: "Quorum"
      assert_text "General Discussion"
      assert_selector "b", text: "Politics & Current Events"
    end
  end
end
