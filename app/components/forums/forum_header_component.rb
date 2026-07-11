module Forums
  class ForumHeaderComponent < ApplicationComponent
    def initialize(title:, description:, subforums: [], new_thread_path: nil, current_user: nil)
      @title = title
      @description = description
      @subforums = subforums
      @new_thread_path = new_thread_path
      @current_user = current_user
    end

    attr_reader :title, :description, :subforums, :new_thread_path, :current_user
  end
end
