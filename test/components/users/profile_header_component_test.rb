require "test_helper"

module Users
  class ProfileHeaderComponentTest < ViewComponent::TestCase
    def base_profile
      { name: "PoliticalJunkie88", rank: "Senior Member", rank_color: "#2455a4", initial: "P", avatar_color: "#2455a4", is_devils_advocate: false }
    end

    test "renders the name, rank, and action buttons" do
      render_inline(ProfileHeaderComponent.new(profile: base_profile))

      assert_text "PoliticalJunkie88"
      assert_text "Senior Member"
      assert_selector "button", text: "Send Message"
      assert_selector "button", text: "Find All Posts"
    end

    test "renders the Devil's Advocate badge only when flagged" do
      render_inline(ProfileHeaderComponent.new(profile: base_profile.merge(is_devils_advocate: true)))
      assert_text "Devil's Advocate"

      render_inline(ProfileHeaderComponent.new(profile: base_profile))
      assert_no_text "Devil's Advocate"
    end
  end
end
