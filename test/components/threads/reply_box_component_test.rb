require "test_helper"

module Threads
  class ReplyBoxComponentTest < ViewComponent::TestCase
    test "renders the reply textarea and submit button" do
      render_inline(ReplyBoxComponent.new)

      assert_selector "textarea[placeholder='Write your reply...']"
      assert_selector "button", text: "Post Reply"
    end
  end
end
