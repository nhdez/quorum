require "test_helper"

module Users
  class RecentPostsComponentTest < ViewComponent::TestCase
    test "renders each post's thread, snippet, and time" do
      posts = [ { thread: "Re: Some thread", snippet: "A snippet.", time: "Today" } ]

      render_inline(RecentPostsComponent.new(posts: posts))

      assert_text "Re: Some thread"
      assert_text "A snippet."
      assert_text "Today"
    end
  end
end
