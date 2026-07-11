require "test_helper"

module Forums
  class CategoryPanelComponentTest < ViewComponent::TestCase
    test "renders the category name and each forum row" do
      forums = [
        { name: "General", desc: "General chat", icon_color: "#333", subforums: nil, lean: nil, threads: "1", posts: "2", last_post: nil },
        { name: "Support", desc: "Get help", icon_color: "#333", subforums: nil, lean: nil, threads: "3", posts: "4", last_post: nil }
      ]

      render_inline(CategoryPanelComponent.new(name: "Community", forums: forums))

      assert_text "Community"
      assert_text "General"
      assert_text "Support"
    end
  end
end
