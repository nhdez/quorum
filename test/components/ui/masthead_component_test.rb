require "test_helper"

module Ui
  class MastheadComponentTest < ViewComponent::TestCase
    test "renders the brand and guest actions when signed out" do
      render_inline(MastheadComponent.new)

      assert_text "Quorum"
      assert_text "Welcome,"
      assert_text "Guest"
      assert_selector "a", text: "Log In"
      assert_selector "a", text: "Register"
    end

    test "renders a welcome message and log out button when signed in" do
      user = users(:one)

      render_inline(MastheadComponent.new(current_user: user))

      assert_text user.email.split("@").first
      assert_selector "button", text: "Log Out"
      assert_no_text "Guest"
    end
  end
end
