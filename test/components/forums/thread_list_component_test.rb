require "test_helper"

module Forums
  class ThreadListComponentTest < ViewComponent::TestCase
    test "renders a row per thread using the given path builder" do
      threads = [
        { marker: nil, title: "Thread A", contested: false, author: "a", author_color: "#333", replies: "1", views: "2", last_post: { user: "a", user_color: "#333", time: "now", avatar_color: "#333", initial: "A" } },
        { marker: nil, title: "Thread B", contested: false, author: "b", author_color: "#333", replies: "3", views: "4", last_post: { user: "b", user_color: "#333", time: "now", avatar_color: "#333", initial: "B" } }
      ]

      render_inline(ThreadListComponent.new(threads: threads, thread_path: ->(t) { "/threads/#{t[:title].parameterize}" }))

      assert_selector "a[href='/threads/thread-a']", text: "Thread A"
      assert_selector "a[href='/threads/thread-b']", text: "Thread B"
    end
  end
end
