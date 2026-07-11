require "test_helper"

module Admin
  class ReportsComponentTest < ViewComponent::TestCase
    test "renders an empty state when there are none" do
      render_inline(ReportsComponent.new(reports: []))

      assert_text "No reports awaiting review."
    end

    test "renders each report's thread, excerpt, and reporter" do
      reports = [ { thread: "Some thread", excerpt: "an excerpt", reporter: "quietobserver", reason: "Personal attack" } ]

      render_inline(ReportsComponent.new(reports: reports))

      assert_text "Some thread"
      assert_text "an excerpt"
      assert_text "quietobserver"
      assert_text "Personal attack"
    end
  end
end
