require "test_helper"

class ForumThreadsControllerTest < ActionDispatch::IntegrationTest
  def create_thread_with_reply
    author = User.create!(email: "threadviewauthor@example.com", password: "password123", password_confirmation: "password123")
    replier = User.create!(email: "threadviewreplier@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "TV Cat", slug: "tv-cat-threadviewtest")
    forum = Forum.create!(forum_category: category, title: "TV Forum", slug: "tv-forum-threadviewtest")
    thread = ForumThread.create!(forum: forum, user: author, title: "Real Thread View Title", slug: "real-thread-view-title", body: "The original post body.")
    ThreadReply.create!(forum_thread: thread, user: replier, body: "A real reply body.")
    [ forum, thread ]
  end

  test "should get show" do
    forum, thread = create_thread_with_reply
    get forum_thread_url(forum, thread)
    assert_response :success
  end

  test "renders the thread's real posts" do
    forum, thread = create_thread_with_reply

    get forum_thread_url(forum, thread)

    assert_match "Real Thread View Title", response.body
    assert_match "The original post body.", response.body
    assert_match "A real reply body.", response.body
    assert_match "threadviewauthor", response.body
    assert_match "threadviewreplier", response.body
  end

  test "increments views_count on each view" do
    forum, thread = create_thread_with_reply

    assert_difference -> { thread.reload.views_count }, 1 do
      get forum_thread_url(forum, thread)
    end
  end
end
