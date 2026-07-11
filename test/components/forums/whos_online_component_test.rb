require "test_helper"

module Forums
  class WhosOnlineComponentTest < ViewComponent::TestCase
    test "renders the summary, each user, and the group legend" do
      users = [
        { name: "Admin", group_color: "#c0392b" },
        { name: "popcorn_kev", group_color: "#333333" }
      ]

      render_inline(WhosOnlineComponent.new(users: users, summary: "There are 2 users online."))

      assert_text "There are 2 users online."
      assert_text "Admin"
      assert_text "popcorn_kev"
      assert_text "Administrator"
      assert_text "Moderator"
    end
  end
end
