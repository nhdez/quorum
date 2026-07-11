require "test_helper"

module Forums
  class ForumHeaderComponentTest < ViewComponent::TestCase
    test "renders title, description, and sub-boards when present" do
      render_inline(ForumHeaderComponent.new(
        title: "Politics & Current Events",
        description: "Debate the issues of the day.",
        subforums: [ "Elections 2026", "International Affairs" ]
      ))

      assert_text "Politics & Current Events"
      assert_text "Debate the issues of the day."
      assert_text "Elections 2026"
      assert_text "International Affairs"
      assert_selector "button", text: "+ New Thread"
    end

    test "omits the sub-boards line when there are none" do
      render_inline(ForumHeaderComponent.new(title: "Site Support", description: "Get help.", subforums: []))

      assert_no_text "Sub-boards"
    end
  end
end
