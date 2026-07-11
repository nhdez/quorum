require "test_helper"

class ForumsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "renders real forum categories and stats" do
    user = User.create!(email: "indextest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Real Category", slug: "real-category-indextest", index_order: 0)
    forum = Forum.create!(forum_category: category, title: "Real Forum", slug: "real-forum-indextest", index_order: 0)
    ForumThread.create!(forum: forum, user: user, title: "Real Thread", slug: "real-thread-indextest", body: "content")

    get root_url

    assert_match "Real Category", response.body
    assert_match "Real Forum", response.body
    assert_match "Real Thread", response.body
    assert_match User.count.to_s, response.body
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
