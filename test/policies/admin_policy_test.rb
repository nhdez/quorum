require "test_helper"

class AdminPolicyTest < ActiveSupport::TestCase
  test "denies a guest (nil user)" do
    assert_not AdminPolicy.new(nil, :admin).access?
  end

  test "denies a signed-in user without the admin role" do
    user = User.create!(email: "regular@example.com", password: "password123", password_confirmation: "password123")
    assert_not AdminPolicy.new(user, :admin).access?
  end

  test "allows a user with the admin role" do
    user = User.create!(email: "admin_role@example.com", password: "password123", password_confirmation: "password123")
    user.add_role(:admin)

    assert AdminPolicy.new(user, :admin).access?
  end
end
