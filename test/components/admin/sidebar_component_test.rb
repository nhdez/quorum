require "test_helper"

module Admin
  class SidebarComponentTest < ViewComponent::TestCase
    test "renders every sidebar link" do
      render_inline(SidebarComponent.new)

      Admin::SidebarComponent::LINKS.each do |link|
        assert_text link[:label]
      end
    end
  end
end
