require "test_helper"

class ThreadReplyTest < ActiveSupport::TestCase
  test "belongs to a user" do
    user = User.create!(email: "replyauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-replytest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-replytest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-replytest", user: user, body: "content")
    reply = ThreadReply.create!(forum_thread: thread, user: user, body: "a reply")

    assert_equal user, reply.user
  end

  test "requires a body" do
    user = User.create!(email: "replyvalidationtest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-replyvalidationtest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-replyvalidationtest")
    thread = ForumThread.create!(forum: forum, user: user, title: "A thread", slug: "a-thread-replyvalidationtest", body: "content")

    reply = ThreadReply.new(forum_thread: thread, user: user, body: "")
    assert_not reply.valid?
    assert_includes reply.errors[:body], "can't be blank"
  end
end
