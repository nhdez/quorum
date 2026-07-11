require "test_helper"

class FactionTest < ActiveSupport::TestCase
  test "requires a name" do
    faction = Faction.new(name: nil, description: "desc")
    assert_not faction.valid?
    assert_includes faction.errors[:name], "can't be blank"
  end

  test "requires a unique name" do
    Faction.create!(name: "Unique Alliance", description: "desc")
    dup = Faction.new(name: "Unique Alliance", description: "another desc")

    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "nullifies users' faction_id when destroyed" do
    faction = Faction.create!(name: "Temporary Bloc", description: "desc")
    user = User.create!(email: "faction_member@example.com", password: "password123", password_confirmation: "password123", faction: faction)

    faction.destroy
    user.reload

    assert_nil user.faction_id
  end
end
