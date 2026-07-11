require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "display_name is the email's local part" do
    user = User.new(email: "skeptical_sam@example.com")
    assert_equal "skeptical_sam", user.display_name
  end

  test "rank_label is Administrator for admins, Member otherwise" do
    user = User.create!(email: "ranktest@example.com", password: "password123", password_confirmation: "password123")
    assert_equal "Member", user.rank_label

    user.add_role(:admin)
    assert_equal "Administrator", user.rank_label
  end

  test "rank_color is red for admins, ink for everyone else" do
    user = User.create!(email: "colortest@example.com", password: "password123", password_confirmation: "password123")
    assert_equal "#1c2733", user.rank_color

    user.add_role(:admin)
    assert_equal "#c0392b", user.rank_color
  end

  test "avatar_color is deterministic for the same user" do
    user = User.create!(email: "avatartest@example.com", password: "password123", password_confirmation: "password123")
    assert_equal user.avatar_color, user.reload.avatar_color
  end

  test "post_count sums threads and replies started by the user" do
    user = User.create!(email: "postcounttest@example.com", password: "password123", password_confirmation: "password123")
    category = ForumCategory.create!(title: "Cat", slug: "cat-postcount")
    forum = Forum.create!(forum_category: category, title: "Forum", slug: "forum-postcount")
    thread = ForumThread.create!(forum: forum, title: "A thread", slug: "a-thread-postcount", user: user)
    ThreadReply.create!(forum_thread: thread, user: user)

    assert_equal 2, user.post_count
  end
end
