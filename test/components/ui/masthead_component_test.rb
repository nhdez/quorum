require "test_helper"

module Ui
  class MastheadComponentTest < ViewComponent::TestCase
    test "renders the brand and guest actions" do
      render_inline(MastheadComponent.new)

      assert_text "Quorum"
      assert_text "Welcome,"
      assert_text "Guest"
      assert_selector "a", text: "Log In"
      assert_selector "a", text: "Register"
    end
  end
end
