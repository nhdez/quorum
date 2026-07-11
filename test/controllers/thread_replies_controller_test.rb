require "test_helper"

class ThreadRepliesControllerTest < ActionDispatch::IntegrationTest
  def create_thread
    author = User.create!(email: "replycontrollerauthor@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Reply Cat", slug: "reply-cat-controllertest")
    forum = Forum.create!(forum_category: category, title: "Reply Forum", slug: "reply-forum-controllertest")
    thread = ForumThread.create!(forum: forum, user: author, title: "Reply Test Thread", slug: "reply-test-thread-controllertest", body: "OP body.")
    [ forum, thread ]
  end

  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
  end

  test "guests are redirected to login" do
    forum, thread = create_thread
    post forum_thread_thread_replies_url(forum, thread), params: { thread_reply: { body: "A reply." } }
    assert_redirected_to new_user_session_path
  end

  test "a signed-in user can post a real reply" do
    forum, thread = create_thread
    user = User.create!(email: "replycontrolleruser@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_difference "ThreadReply.count", 1 do
      post forum_thread_thread_replies_url(forum, thread), params: { thread_reply: { body: "A real reply." } }
    end

    reply = ThreadReply.order(:created_at).last
    assert_equal user, reply.user
    assert_redirected_to forum_thread_path(forum, thread)
  end

  test "posting a blank reply redirects back with an error" do
    forum, thread = create_thread
    user = User.create!(email: "badreplycontrolleruser@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_no_difference "ThreadReply.count" do
      post forum_thread_thread_replies_url(forum, thread), params: { thread_reply: { body: "" } }
    end

    assert_redirected_to forum_thread_path(forum, thread)
    follow_redirect!
    assert_match "can&#39;t be blank", response.body
  end
end
