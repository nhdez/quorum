require "test_helper"

module Admin
  class StatCardComponentTest < ViewComponent::TestCase
    test "renders the label and value" do
      render_inline(StatCardComponent.new(label: "Total Members", value: "24,801"))

      assert_text "Total Members"
      assert_text "24,801"
    end
  end
end
