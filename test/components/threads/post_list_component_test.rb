require "test_helper"

module Threads
  class PostListComponentTest < ViewComponent::TestCase
    test "renders a PostComponent per post" do
      posts = [
        { user: "a", user_color: "#333", rank: "Member", avatar_color: "#333", initial: "A", joined: "2020", post_count: "1", reputation: "0", time: "now", number: "1", highlighted: false, affiliation_name: nil, affiliation_color: nil, is_devils_advocate: false, ai_flag_reason: nil, signature: nil, body: "First post" },
        { user: "b", user_color: "#333", rank: "Member", avatar_color: "#333", initial: "B", joined: "2020", post_count: "1", reputation: "0", time: "now", number: "2", highlighted: false, affiliation_name: nil, affiliation_color: nil, is_devils_advocate: false, ai_flag_reason: nil, signature: nil, body: "Second post" }
      ]

      render_inline(PostListComponent.new(posts: posts))

      assert_text "First post"
      assert_text "Second post"
    end
  end
end
