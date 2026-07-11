require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get member_url(id: users(:one).id)
    assert_response :success
  end

  test "renders the profile content for the real user" do
    get member_url(id: users(:one).id)

    assert_match users(:one).display_name, response.body
    assert_match "Total Posts", response.body
  end
end
