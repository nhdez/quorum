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

  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
  end

  test "guests are redirected to login when trying to start a new thread" do
    forum, _thread = create_thread_with_reply
    get new_forum_thread_url(forum)
    assert_redirected_to new_user_session_path
  end

  test "a signed-in user can create a real thread" do
    forum, _thread = create_thread_with_reply
    user = User.create!(email: "newthreadcreator@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_difference "ForumThread.count", 1 do
      post forum_threads_url(forum), params: { forum_thread: { title: "A brand new thread", body: "Its opening post." } }
    end

    new_thread = ForumThread.order(:created_at).last
    assert_equal user, new_thread.user
    assert_redirected_to forum_thread_path(forum, new_thread)
  end

  test "creating a thread with a blank title re-renders the form" do
    forum, _thread = create_thread_with_reply
    user = User.create!(email: "badthreadcreator@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_no_difference "ForumThread.count" do
      post forum_threads_url(forum), params: { forum_thread: { title: "", body: "Body without a title." } }
    end

    assert_response :unprocessable_content
  end
end
