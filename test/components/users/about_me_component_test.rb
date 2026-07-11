require "test_helper"

module Users
  class AboutMeComponentTest < ViewComponent::TestCase
    test "renders the bio and signature when present" do
      render_inline(AboutMeComponent.new(bio: "Hello there.", signature: "Some quote."))

      assert_text "Hello there."
      assert_text "Some quote."
    end

    test "omits the signature line when blank" do
      render_inline(AboutMeComponent.new(bio: "Hello there.", signature: nil))

      assert_text "Hello there."
      assert_no_text "Signature:"
    end
  end
end
