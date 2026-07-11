require "test_helper"

module Threads
  class ReplyBoxComponentTest < ViewComponent::TestCase
    test "renders a real form posting to the given reply path" do
      render_inline(ReplyBoxComponent.new(reply_path: "/forums/x/threads/y/replies"))

      assert_selector "form[action='/forums/x/threads/y/replies']"
      assert_selector "input[type='submit'][value='Post Reply']"
    end
  end
end
