require "test_helper"

module Ui
  class AnnouncementBarComponentTest < ViewComponent::TestCase
    test "renders the given text" do
      render_inline(AnnouncementBarComponent.new(text: "Read the rules before posting."))

      assert_text "Announcement:"
      assert_text "Read the rules before posting."
    end
  end
end
