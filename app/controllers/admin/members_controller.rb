module Admin
  class MembersController < BaseController
    before_action :set_admin_nav

    def index
      page = paginate(User.order(created_at: :desc), per_page: 25)
      @users = page.records
      @pages = page_links(page, path: ->(number) { admin_members_path(page: number) })
    end

    def toggle_admin
      user = User.find(params[:id])

      if user == current_user
        redirect_to admin_members_path, alert: "You can't change your own admin status."
        return
      end

      user.has_role?(:admin) ? user.remove_role(:admin) : user.add_role(:admin)
      redirect_to admin_members_path, notice: "#{user.email} updated."
    end

    def toggle_lock
      user = User.find(params[:id])

      if user == current_user
        redirect_to admin_members_path, alert: "You can't lock your own account."
        return
      end

      user.access_locked? ? user.unlock_access! : user.lock_access!
      redirect_to admin_members_path, notice: "#{user.email} updated."
    end

    def destroy
      user = User.find(params[:id])

      if user == current_user
        redirect_to admin_members_path, alert: "You can't remove your own account."
        return
      end

      user.destroy
      redirect_to admin_members_path, notice: "#{user.email} removed."
    end

    private

    def set_admin_nav
      @admin_nav_current = :members
    end
  end
end
