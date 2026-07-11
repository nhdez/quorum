require "test_helper"

class ForumsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "renders the forum categories" do
    get root_url

    assert_match "Politics &amp; Current Events", response.body
    assert_match "Announcements &amp; News", response.body
  end

  test "should get show" do
    get forum_url(id: "politics-current-events")
    assert_response :success
  end

  test "renders the forum's threads" do
    get forum_url(id: "politics-current-events")

    assert_match "Midterm predictions thread", response.body
    assert_match "Forum Rules", response.body
  end
end
