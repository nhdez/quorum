require "test_helper"

module Admin
  class SidebarComponentTest < ViewComponent::TestCase
    test "renders every sidebar link" do
      render_inline(SidebarComponent.new)

      Admin::SidebarComponent::LINKS.each do |link|
        assert_text link[:label]
      end
    end

    test "renders real links for pages that exist" do
      render_inline(SidebarComponent.new)

      assert_selector "a[href='#{Rails.application.routes.url_helpers.admin_dashboard_path}']", text: "Dashboard"
      assert_selector "a[href='#{Rails.application.routes.url_helpers.admin_members_path}']", text: "Members"
      assert_selector "a[href='#{Rails.application.routes.url_helpers.admin_announcements_path}']", text: "Announcements"
      assert_selector "a[href='#{Rails.application.routes.url_helpers.edit_admin_smtp_settings_path}']", text: "Email (SMTP)"
      assert_selector "a[href='#{Rails.application.routes.url_helpers.edit_admin_ai_settings_path}']", text: "Settings"
    end

    test "leaves not-yet-built sections as non-links" do
      render_inline(SidebarComponent.new)

      assert_selector "div", text: "AI Bias Bot"
      assert_no_selector "a", text: "AI Bias Bot"
    end
  end
end
