require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    def sign_in_as(user)
      post user_session_path, params: { user: { email: user.email, password: "password123" } }
    end

    test "redirects guests to the login page" do
      get admin_dashboard_url
      assert_redirected_to new_user_session_path
    end

    test "redirects signed-in non-admins to the root path" do
      user = User.create!(email: "nonadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      sign_in_as(user)

      get admin_dashboard_url
      assert_redirected_to root_path
    end

    test "allows a user with the admin role" do
      admin = User.create!(email: "realadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      admin.add_role(:admin)
      sign_in_as(admin)

      get admin_dashboard_url
      assert_response :success
    end

    test "shows real counts and pending registrations" do
      admin = User.create!(email: "statsadmin@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
      admin.add_role(:admin)
      User.create!(email: "unconfirmed_dashboard@example.com", password: "password123", password_confirmation: "password123")
      sign_in_as(admin)

      get admin_dashboard_url

      assert_match "unconfirmed_dashboard@example.com", response.body
      assert_match User.count.to_s, response.body
    end
  end
end
