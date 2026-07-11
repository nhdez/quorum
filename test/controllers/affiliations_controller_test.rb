require "test_helper"

class AffiliationsControllerTest < ActionDispatch::IntegrationTest
  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
  end

  test "should get index" do
    get affiliations_url
    assert_response :success
  end

  test "guests are redirected to login when trying to join" do
    faction = Faction.create!(name: "Join Redirect Test", description: "desc", color: "#6b4fa0")

    patch join_affiliation_url(faction)

    assert_redirected_to new_user_session_path
  end

  test "a signed-in user can join a faction" do
    faction = Faction.create!(name: "Real Join Test", description: "desc", color: "#6b4fa0")
    user = User.create!(email: "real_joiner@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    patch join_affiliation_url(faction)
    user.reload

    assert_equal faction.id, user.faction_id
  end

  test "joining the same faction again leaves it" do
    faction = Faction.create!(name: "Toggle Join Test", description: "desc", color: "#6b4fa0")
    user = User.create!(email: "toggler@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current, faction: faction)
    sign_in_as(user)

    patch join_affiliation_url(faction)
    user.reload

    assert_nil user.faction_id
  end

  test "a signed-in user can propose a new affiliation" do
    user = User.create!(email: "proposer@example.com", password: "password123", password_confirmation: "password123", confirmed_at: Time.current)
    sign_in_as(user)

    assert_difference "Faction.count", 1 do
      post affiliations_url, params: { faction: { name: "Brand New Bloc", description: "A new group." } }
    end

    assert_equal "A new group.", Faction.find_by(name: "Brand New Bloc").description
  end

  test "guests cannot propose a new affiliation" do
    assert_no_difference "Faction.count" do
      post affiliations_url, params: { faction: { name: "Should Not Exist", description: "desc" } }
    end
  end
end
