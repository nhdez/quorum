require "test_helper"

module Threads
  class VoteBarComponentTest < ViewComponent::TestCase
    test "renders each choice's name, percentage, and the total" do
      choices = [
        { id: "a", name: "Progressive Alliance", color: "#6b4fa0", pct: 60 },
        { id: "b", name: "Liberty Caucus", color: "#a0524f", pct: 40 }
      ]

      render_inline(VoteBarComponent.new(choices: choices, total: 100))

      assert_text "Progressive Alliance 60%"
      assert_text "Liberty Caucus 40%"
      assert_text "100 votes"
    end
  end
end
