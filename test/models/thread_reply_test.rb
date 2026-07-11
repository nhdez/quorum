require "test_helper"

class ThreadReplyTest < ActiveSupport::TestCase
  test "belongs to a user" do
    user = User.create!(email: "replyauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-replytest")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-replytest")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-replytest", user: user)
    reply = ThreadReply.create!(forum_thread: thread, user: user)

    assert_equal user, reply.user
  end
end
