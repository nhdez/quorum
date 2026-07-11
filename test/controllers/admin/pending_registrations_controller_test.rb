require "test_helper"

module Admin
  class PendingRegistrationsControllerTest < ActionDispatch::IntegrationTest
    def sign_in_admin
      admin = User.create!(email: "actionadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      admin.add_role(:admin)
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
    end

    test "confirming approves the pending user" do
      sign_in_admin
      pending_user = User.create!(email: "to_confirm@example.com", password: "password123", password_confirmation: "password123")

      patch confirm_admin_pending_registration_url(pending_user)
      pending_user.reload

      assert_redirected_to admin_dashboard_path
      assert pending_user.confirmed_at.present?
    end

    test "destroying rejects and deletes the pending user" do
      sign_in_admin
      pending_user = User.create!(email: "to_reject@example.com", password: "password123", password_confirmation: "password123")

      assert_difference "User.count", -1 do
        delete admin_pending_registration_url(pending_user)
      end

      assert_redirected_to admin_dashboard_path
    end

    test "a non-admin cannot confirm a pending registration" do
      user = User.create!(email: "notanadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      post user_session_path, params: { user: { email: user.email, password: "password123" } }
      pending_user = User.create!(email: "protected@example.com", password: "password123", password_confirmation: "password123")

      patch confirm_admin_pending_registration_url(pending_user)
      pending_user.reload

      assert_redirected_to root_path
      assert_nil pending_user.confirmed_at
    end
  end
end
