require "test_helper"

module Ui
  class FooterComponentTest < ViewComponent::TestCase
    test "renders the footer links" do
      render_inline(FooterComponent.new)

      assert_text "Quorum"
      assert_selector "a", text: "Contact Us"
      assert_selector "a", text: "Admin CP"
    end
  end
end
