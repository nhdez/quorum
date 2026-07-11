require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get member_url(id: "political-junkie-88")
    assert_response :success
  end

  test "renders the profile content" do
    get member_url(id: "political-junkie-88")

    assert_match "PoliticalJunkie88", response.body
    assert_match "Progressive Alliance", response.body
    assert_match "Total Posts", response.body
  end
end
