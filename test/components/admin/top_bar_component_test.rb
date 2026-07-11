require "test_helper"

module Admin
  class TopBarComponentTest < ViewComponent::TestCase
    test "renders the current user's identity and a return link" do
      user = User.create!(email: "topbar@example.com", password: "password123", password_confirmation: "password123")

      render_inline(TopBarComponent.new(current_user: user))

      assert_text "topbar"
      assert_selector "a", text: "Return to Forum"
    end
  end
end
