require "test_helper"

module Forums
  class ForumRowComponentTest < ViewComponent::TestCase
    def base_forum
      {
        name: "Off-Topic Lounge", desc: "Anything goes.", icon_color: "#8a8f9a",
        subforums: nil, lean: nil, threads: "10", posts: "20", last_post: nil
      }
    end

    test "renders forum name, description and counts" do
      render_inline(ForumRowComponent.new(forum: base_forum))

      assert_text "Off-Topic Lounge"
      assert_text "Anything goes."
      assert_text "10 Threads"
      assert_text "20 Posts"
    end

    test "shows an empty state when there is no last post" do
      render_inline(ForumRowComponent.new(forum: base_forum))

      assert_text "No posts yet"
    end

    test "renders last post details when present" do
      forum = base_forum.merge(
        last_post: { thread: "Welcome thread", user: "newbie_nancy", user_color: "#333333", time: "Today", avatar_color: "#7d97c2", initial: "N" }
      )

      render_inline(ForumRowComponent.new(forum: forum))

      assert_text "Welcome thread"
      assert_text "newbie_nancy"
      assert_no_text "No posts yet"
    end

    test "renders sub-board text only when present" do
      forum = base_forum.merge(subforums: "Sub A, Sub B")
      render_inline(ForumRowComponent.new(forum: forum))

      assert_text "Sub-boards: Sub A, Sub B"
    end
  end
end
