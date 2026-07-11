require "test_helper"

module AiFlags
  class FlagLogComponentTest < ViewComponent::TestCase
    test "renders each flag's thread, excerpt, reason, and author" do
      flags = [
        { thread: "Some thread", excerpt: "a biased excerpt", reason: "Possible ad hominem.", user: "SunTzuFan", user_color: "#2455a4", time: "Today" }
      ]

      render_inline(FlagLogComponent.new(flags: flags))

      assert_text "Some thread"
      assert_text "a biased excerpt"
      assert_text "Possible ad hominem."
      assert_text "SunTzuFan"
    end
  end
end
