require "test_helper"

class DevisePagesTest < ActionDispatch::IntegrationTest
  test "renders the login page" do
    get new_user_session_path
    assert_response :success
    assert_select "input[name='user[email]']"
  end

  test "renders the registration page" do
    get new_user_registration_path
    assert_response :success
    assert_select "input[name='user[email]']"
    assert_select "input[name='user[password_confirmation]']"
  end

  test "logs a confirmed user in and reflects it in the masthead" do
    user = User.create!(email: "signin_test@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)

    post user_session_path, params: { user: { email: user.email, password: "password123" } }
    follow_redirect!

    assert_match "signin_test", response.body
    assert_match "Log Out", response.body
  end
end
