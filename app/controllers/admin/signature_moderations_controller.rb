module Admin
  class SignatureModerationsController < BaseController
    before_action :set_admin_nav

    def index
      @users = User.where(signature_pending_review: true).order(:created_at)
    end

    def approve
      user = User.find(params[:id])
      user.update!(signature_pending_review: false)
      redirect_to admin_signature_moderations_path, notice: "#{user.display_name}'s signature approved."
    end

    def reject
      user = User.find(params[:id])
      user.update!(signature: nil)
      redirect_to admin_signature_moderations_path, notice: "#{user.display_name}'s signature rejected and removed."
    end

    private

    def set_admin_nav
      @admin_nav_current = :signature_moderations
    end
  end
end
