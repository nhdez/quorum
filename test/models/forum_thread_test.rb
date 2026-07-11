require "test_helper"

class ForumThreadTest < ActiveSupport::TestCase
  test "belongs to a user" do
    user = User.create!(email: "threadauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-threadtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-threadtest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-threadtest", user: user)

    assert_equal user, thread.user
  end

  test "views_count defaults to 0" do
    user = User.create!(email: "viewstest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-viewstest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-viewstest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-viewstest", user: user)

    assert_equal 0, thread.views_count
  end
end
