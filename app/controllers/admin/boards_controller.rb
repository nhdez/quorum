module Admin
  class BoardsController < BaseController
    def index
      @admin_nav_current = :boards
      @categories = ForumCategory.ordered
      @top_level_forums_by_category = Forum.top_level.ordered.includes(:subforums).group_by(&:forum_category_id)
      @new_forum_category = ForumCategory.new
      @new_forum = Forum.new
    end
  end
end
