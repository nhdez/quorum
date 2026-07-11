require "test_helper"

class ForumThreadsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get forum_thread_url(forum_id: "politics-current-events", id: "midterm-predictions-thread")
    assert_response :success
  end

  test "renders the thread's posts" do
    get forum_thread_url(forum_id: "politics-current-events", id: "midterm-predictions-thread")

    assert_match "Midterm predictions thread", response.body
    assert_match "PoliticalJunkie88", response.body
    assert_match "Progressive Alliance", response.body
  end
end
