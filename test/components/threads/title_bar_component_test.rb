require "test_helper"

module Threads
  class TitleBarComponentTest < ViewComponent::TestCase
    test "renders the thread title" do
      render_inline(TitleBarComponent.new(title: "Midterm predictions thread"))

      assert_text "Midterm predictions thread"
    end
  end
end
