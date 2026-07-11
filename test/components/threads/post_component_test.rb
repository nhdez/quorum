require "test_helper"

module Threads
  class PostComponentTest < ViewComponent::TestCase
    def base_post
      {
        user: "PoliticalJunkie88", user_color: "#2455a4", rank: "Senior Member",
        avatar_color: "#2455a4", initial: "P", joined: "Mar 2019", post_count: "4,821",
        time: "Today, 08:02 AM", number: "1", highlighted: false,
        affiliation_name: nil, affiliation_color: nil, is_devils_advocate: false,
        ai_flag_reason: nil, signature: nil, body: "Hello world."
      }
    end

    test "renders the author, post body, and post number" do
      render_inline(PostComponent.new(post: base_post))

      assert_text "PoliticalJunkie88"
      assert_text "Hello world."
      assert_text "Post #1"
    end

    test "renders the affiliation badge only when present" do
      render_inline(PostComponent.new(post: base_post.merge(affiliation_name: "Progressive Alliance", affiliation_color: "#6b4fa0")))
      assert_text "Progressive Alliance"

      render_inline(PostComponent.new(post: base_post))
      assert_no_text "Progressive Alliance"
    end

    test "renders the Devil's Advocate badge only when flagged" do
      render_inline(PostComponent.new(post: base_post.merge(is_devils_advocate: true)))
      assert_text "Devil's Advocate"
    end

    test "renders the AI flag notice only when a reason is given" do
      render_inline(PostComponent.new(post: base_post.merge(ai_flag_reason: "Reads like an ad hominem.")))

      assert_text "AI Flag:"
      assert_text "Reads like an ad hominem."
    end

    test "renders the signature only when present" do
      render_inline(PostComponent.new(post: base_post.merge(signature: "Some signature.")))
      assert_text "Some signature."
    end

    test "does not render a reputation line" do
      render_inline(PostComponent.new(post: base_post))
      assert_no_text "Reputation"
    end
  end
end
