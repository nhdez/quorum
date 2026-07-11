require "test_helper"

module Forums
  class ForumHeaderComponentTest < ViewComponent::TestCase
    test "renders title, description, and sub-boards when present" do
      user = User.create!(email: "headercontenttest@example.com", password: "password123", password_confirmation: "password123")
      render_inline(ForumHeaderComponent.new(
        title: "Politics & Current Events",
        description: "Debate the issues of the day.",
        subforums: [ { name: "Elections 2026", path: "/forums/elections-2026" }, { name: "International Affairs", path: "/forums/international-affairs" } ],
        new_thread_path: "/forums/x/threads/new",
        current_user: user
      ))

      assert_text "Politics & Current Events"
      assert_text "Debate the issues of the day."
      assert_selector "a[href='/forums/elections-2026']", text: "Elections 2026"
      assert_selector "a[href='/forums/international-affairs']", text: "International Affairs"
      assert_selector "a", text: "+ New Thread"
    end

    test "omits the sub-boards line when there are none" do
      render_inline(ForumHeaderComponent.new(title: "Site Support", description: "Get help.", subforums: []))

      assert_no_text "Sub-boards"
    end

    test "links + New Thread to the real path when signed in" do
      user = User.create!(email: "headertest@example.com", password: "password123", password_confirmation: "password123")
      render_inline(ForumHeaderComponent.new(title: "T", description: "D", new_thread_path: "/forums/x/threads/new", current_user: user))

      assert_selector "a[href='/forums/x/threads/new']", text: "+ New Thread"
    end

    test "shows a login prompt when signed out" do
      render_inline(ForumHeaderComponent.new(title: "T", description: "D", new_thread_path: "/forums/x/threads/new", current_user: nil))

      assert_selector "a", text: "Log in to post"
    end
  end
end
