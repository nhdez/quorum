require "test_helper"

module Affiliations
  class FactionCardComponentTest < ViewComponent::TestCase
    test "shows a login prompt for guests" do
      faction = Faction.create!(name: "Guest Test Alliance", description: "desc", color: "#6b4fa0")

      render_inline(FactionCardComponent.new(faction: faction, current_user: nil))

      assert_text "Guest Test Alliance"
      assert_selector "a", text: "Log in to join"
    end

    test "shows Join Affiliation for a signed-in user who hasn't joined" do
      faction = Faction.create!(name: "Join Test Alliance", description: "desc", color: "#6b4fa0")
      user = User.create!(email: "joiner@example.com", password: "password123", password_confirmation: "password123")

      render_inline(FactionCardComponent.new(faction: faction, current_user: user))

      assert_selector "button", text: "Join Affiliation"
    end

    test "shows Joined for the user's current faction" do
      faction = Faction.create!(name: "Joined Test Alliance", description: "desc", color: "#6b4fa0")
      user = User.create!(email: "member@example.com", password: "password123", password_confirmation: "password123", faction: faction)

      render_inline(FactionCardComponent.new(faction: faction, current_user: user))

      assert_text "Joined"
    end
  end
end
