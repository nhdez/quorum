module Admin
  class ForumCategoriesController < BaseController
    def create
      category = ForumCategory.new(forum_category_params)
      category.index_order = (ForumCategory.maximum(:index_order) || -1) + 1

      if category.save
        redirect_to admin_boards_path, notice: "Category created."
      else
        redirect_to admin_boards_path, alert: category.errors.full_messages.to_sentence
      end
    end

    def update
      category = ForumCategory.find(params[:id])

      if category.update(forum_category_params)
        redirect_to admin_boards_path, notice: "Category updated."
      else
        redirect_to admin_boards_path, alert: category.errors.full_messages.to_sentence
      end
    end

    def destroy
      ForumCategory.find(params[:id]).destroy
      redirect_to admin_boards_path, notice: "Category deleted."
    end

    def reorder
      params.require(:ids).each_with_index do |id, index|
        ForumCategory.where(id: id).update_all(index_order: index)
      end
      head :ok
    end

    private

    def forum_category_params
      params.require(:forum_category).permit(:title, :description, :is_visible)
    end
  end
end
