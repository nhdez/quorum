module Admin
  class PendingRegistrationsController < BaseController
    def confirm
      user = User.find(params[:id])
      user.confirm
      redirect_to admin_dashboard_path, notice: "#{user.email} has been approved."
    end

    def destroy
      user = User.find(params[:id])
      user.destroy
      redirect_to admin_dashboard_path, notice: "Registration rejected."
    end
  end
end
