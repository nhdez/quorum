require "test_helper"

module Admin
  class PendingRegistrationsComponentTest < ViewComponent::TestCase
    test "renders an empty state when there are none" do
      render_inline(PendingRegistrationsComponent.new(users: User.none))

      assert_text "No pending registrations."
    end

    test "renders a row with Approve/Reject actions per user" do
      user = User.create!(email: "pending@example.com", password: "password123", password_confirmation: "password123")

      render_inline(PendingRegistrationsComponent.new(users: [ user ]))

      assert_text "pending@example.com"
      assert_selector "button", text: "Approve"
      assert_selector "button", text: "Reject"
    end
  end
end
