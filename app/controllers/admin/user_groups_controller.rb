module Admin
  class UserGroupsController < BaseController
    before_action :set_admin_nav

    def index
      UserGroup.ensure_system_groups!
      @user_groups = UserGroup.ordered
      @new_user_group = UserGroup.new
    end

    def create
      group = UserGroup.new(user_group_params)

      if group.save
        redirect_to admin_user_groups_path, notice: "Group created."
      else
        redirect_to admin_user_groups_path, alert: group.errors.full_messages.to_sentence
      end
    end

    def update
      group = UserGroup.find(params[:id])
      attrs = user_group_params
      attrs = attrs.except(:name) if group.system_group?

      if group.update(attrs)
        redirect_to admin_user_groups_path, notice: "Group updated."
      else
        redirect_to admin_user_groups_path, alert: group.errors.full_messages.to_sentence
      end
    end

    def destroy
      group = UserGroup.find(params[:id])

      if group.destroy
        redirect_to admin_user_groups_path, notice: "Group deleted."
      else
        redirect_to admin_user_groups_path, alert: group.errors.full_messages.to_sentence
      end
    end

    private

    def set_admin_nav
      @admin_nav_current = :user_groups
    end

    def user_group_params
      params.require(:user_group).permit(:name, :badge_color, :banner)
    end
  end
end
