require "test_helper"

module Forums
  class BiasMeterComponentTest < ViewComponent::TestCase
    test "labels a centrist value as Center" do
      render_inline(BiasMeterComponent.new(value: 50, posts_analyzed: "1,000", history: [ 40, 50, 60 ]))

      assert_text "Center"
      assert_text "1,000 posts"
    end

    test "labels a low value as Strongly Left" do
      render_inline(BiasMeterComponent.new(value: 5, posts_analyzed: "1,000"))

      assert_text "Strongly Left"
    end

    test "labels a high value as Strongly Right" do
      render_inline(BiasMeterComponent.new(value: 95, posts_analyzed: "1,000"))

      assert_text "Strongly Right"
    end

    test "renders a sparkline point for each history value" do
      render_inline(BiasMeterComponent.new(value: 50, posts_analyzed: "1,000", history: [ 10, 20, 30 ]))

      points = page.find("polyline", visible: :all)[:points]
      assert_equal 3, points.split(" ").length
    end
  end
end
