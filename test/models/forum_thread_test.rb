require "test_helper"

class ForumThreadTest < ActiveSupport::TestCase
  test "belongs to a user" do
    user = User.create!(email: "threadauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-threadtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-threadtest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-threadtest", user: user, body: "content")

    assert_equal user, thread.user
  end

  test "views_count defaults to 0" do
    user = User.create!(email: "viewstest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-viewstest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-viewstest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-viewstest", user: user, body: "content")

    assert_equal 0, thread.views_count
  end

  test "requires a title and a body" do
    user = User.create!(email: "validationtest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-validationtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-validationtest")

    thread = ForumThread.new(forum: forum, user: user, title: "", body: "")
    assert_not thread.valid?
    assert_includes thread.errors[:title], "can't be blank"
    assert_includes thread.errors[:body], "can't be blank"
  end
end
