require "test_helper"

module Forums
  class ThreadRowComponentTest < ViewComponent::TestCase
    def base_thread
      {
        marker: nil, title: "Site feedback thread", contested: false,
        author: "newbie_nancy", author_color: "#333333", replies: "5", views: "100",
        last_post: { user: "Admin", user_color: "#c0392b", time: "Today", avatar_color: "#c0392b", initial: "A" }
      }
    end

    test "renders the thread title, counts, and last post" do
      render_inline(ThreadRowComponent.new(thread: base_thread, path: "/forums/x/threads/y"))

      assert_selector "a[href='/forums/x/threads/y']", text: "Site feedback thread"
      assert_text "5 Replies"
      assert_text "100 Views"
      assert_text "Admin"
    end

    test "shows a contested badge only when contested" do
      render_inline(ThreadRowComponent.new(thread: base_thread.merge(contested: true)))
      assert_text "Contested"

      render_inline(ThreadRowComponent.new(thread: base_thread))
      assert_no_text "Contested"
    end
  end
end
