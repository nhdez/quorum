require "test_helper"

module Users
  class AffiliationPanelComponentTest < ViewComponent::TestCase
    test "renders the affiliation name" do
      render_inline(AffiliationPanelComponent.new(affiliation: { name: "Progressive Alliance", color: "#6b4fa0", is_rep: false }))

      assert_text "Progressive Alliance"
      assert_no_text "ELECTED REPRESENTATIVE"
    end

    test "renders the elected representative badge when applicable" do
      render_inline(AffiliationPanelComponent.new(affiliation: { name: "Liberty Caucus", color: "#a0524f", is_rep: true }))

      assert_text "ELECTED REPRESENTATIVE"
    end
  end
end
