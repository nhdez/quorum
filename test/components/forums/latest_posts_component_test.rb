require "test_helper"

module Forums
  class LatestPostsComponentTest < ViewComponent::TestCase
    test "renders each post's title, author and prefix" do
      posts = [
        { prefix: "RE:", title: "Midterm predictions thread", user: "SunTzuFan", user_color: "#2455a4", time: "Today" },
        { prefix: "", title: "What are you watching tonight?", user: "popcorn_kev", user_color: "#333333", time: "Today" }
      ]

      render_inline(LatestPostsComponent.new(posts: posts))

      assert_text "RE:"
      assert_text "Midterm predictions thread"
      assert_text "SunTzuFan"
      assert_text "What are you watching tonight?"
    end
  end
end
