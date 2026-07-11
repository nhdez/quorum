module Admin
  class ForumsController < BaseController
    def create
      forum = Forum.new(forum_params)
      siblings = forum.parent_forum_id.present? ? Forum.where(parent_forum_id: forum.parent_forum_id) : Forum.where(forum_category_id: forum.forum_category_id, parent_forum_id: nil)
      forum.index_order = (siblings.maximum(:index_order) || -1) + 1

      if forum.save
        redirect_to admin_boards_path, notice: "Forum created."
      else
        redirect_to admin_boards_path, alert: forum.errors.full_messages.to_sentence
      end
    end

    def update
      forum = Forum.find(params[:id])

      if forum.update(forum_params)
        redirect_to admin_boards_path, notice: "Forum updated."
      else
        redirect_to admin_boards_path, alert: forum.errors.full_messages.to_sentence
      end
    end

    def destroy
      Forum.find(params[:id]).destroy
      redirect_to admin_boards_path, notice: "Forum deleted."
    end

    def reorder
      params.require(:ids).each_with_index do |id, index|
        Forum.where(id: id).update_all(index_order: index)
      end
      head :ok
    end

    private

    def forum_params
      params.require(:forum).permit(:title, :description, :forum_category_id, :parent_forum_id, :is_visible).tap do |attrs|
        attrs[:parent_forum_id] = nil if attrs[:parent_forum_id].blank?
      end
    end
  end
end
