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
    category = ForumCategory.create!(title: "Show Cat", slug: "show-cat-controllertest")
    forum = Forum.create!(forum_category: category, title: "Show Forum", slug: "show-forum-controllertest")

    get forum_url(forum)
    assert_response :success
  end

  test "renders the forum's real threads" do
    user = User.create!(email: "showthreadtest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Show Cat 2", slug: "show-cat-2-controllertest")
    forum = Forum.create!(forum_category: category, title: "Show Forum 2", slug: "show-forum-2-controllertest")
    ForumThread.create!(forum: forum, user: user, title: "Real Thread Title", slug: "real-thread-title-controllertest", body: "content")

    get forum_url(forum)

    assert_match "Real Thread Title", response.body
    assert_match user.display_name, response.body
  end
end
